resource "google_compute_instance" "bindplane_control" {
  name         = "bindplane-control-2"
  machine_type = "e2-standard-4"
  zone         = var.zone

  tags = ["bindplane"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-SCRIPT
#!/bin/bash
set -euxo pipefail

LOG="/var/log/bindplane-startup.log"
exec > >(tee -a "$LOG") 2>&1

export DEBIAN_FRONTEND=noninteractive

LICENSE="${var.bindplane_license}"
ADMIN_USER="${var.bindplane_admin_user}"
ADMIN_PASS="${var.bindplane_admin_password}"
PORT="${var.bindplane_port}"

PUBLIC_IP=$(curl -sf -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

echo "==== Installing OS packages ===="
apt-get update -y
apt-get install -y curl unzip postgresql postgresql-contrib

echo "==== Starting PostgreSQL ===="
systemctl enable postgresql
systemctl start postgresql
systemctl status postgresql --no-pager

echo "==== Configuring PostgreSQL ===="
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${var.pg_user}'" | grep -q 1 || \
  sudo -u postgres psql -c "CREATE ROLE ${var.pg_user} LOGIN PASSWORD '${var.pg_password}';"

sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='${var.pg_database}'" | grep -q 1 || \
  sudo -u postgres createdb -O ${var.pg_user} ${var.pg_database}

echo "==== Installing Bindplane (NO init) ===="
curl -fsSL https://storage.googleapis.com/bindplane-op-releases/bindplane/latest/install-linux.sh -o /tmp/install.sh
bash /tmp/install.sh
rm -f /tmp/install.sh

echo "==== Writing Bindplane config ===="
mkdir -p /etc/bindplane

cat <<EOF >/etc/bindplane/config.yaml
apiVersion: bindplane.observiq.com/v1
license: $LICENSE

auth:
  type: system
  username: $ADMIN_USER
  password: $ADMIN_PASS

network:
  host: 0.0.0.0
  port: "$PORT"
  remoteURL: http://$PUBLIC_IP:$PORT

store:
  type: postgres
  postgres:
    host: localhost
    port: "5432"
    database: ${var.pg_database}
    username: ${var.pg_user}
    password: ${var.pg_password}
    sslmode: ${var.pg_sslmode}

advanced:
  server:
    listen: 0.0.0.0:$PORT
EOF

chmod 600 /etc/bindplane/config.yaml

echo "==== Initializing Bindplane server with config ===="
BINDPLANE_CONFIG_HOME=/var/lib/bindplane \
  /usr/local/bin/bindplane init server \
  --config /etc/bindplane/config.yaml

echo "==== Enabling & starting Bindplane ===="
systemctl daemon-reload
systemctl enable bindplane
systemctl start bindplane

echo "==== Bindplane startup completed successfully ===="
SCRIPT
}
