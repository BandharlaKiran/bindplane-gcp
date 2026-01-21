resource "google_compute_instance" "bindplane_dataplane" {
  count        = var.dataplane_count
  name         = "bindplane-dataplane-${count.index + 1}"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["bindplane-dataplane"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-SCRIPT
#!/bin/bash
set -euxo pipefail

LOG="/var/log/bindplane-dataplane-startup.log"
exec > >(tee -a "$LOG") 2>&1

export DEBIAN_FRONTEND=noninteractive

echo "===== Bindplane Dataplane startup begin ====="

############################################
# Install prerequisites
############################################
apt-get update -y
apt-get install -y curl ca-certificates

############################################
# Install Bindplane Dataplane Agent
############################################
# This is the OFFICIAL supported install method
sudo sh -c "$(curl -fsSlL 'https://bdot.bindplane.com/v1.91.0/install_unix.sh')" install_unix.sh \
  -e 'ws://${google_compute_instance.bindplane_control.network_interface[0].access_config[0].nat_ip}:3001/v1/opamp' \
  -s '${var.bindplane_agent_token}' \
  -v '1.91.0' \
  -k 'install_id=dataplane-${count.index + 1}'

############################################
# Ensure service is enabled & running
############################################
systemctl daemon-reload

# Discover and start the correct service
systemctl list-unit-files | grep -E 'bindplane|observiq|otel' || true

# Most common service name created by installer
if systemctl list-unit-files | grep -q observiq-otel-collector; then
  systemctl enable observiq-otel-collector
  systemctl restart observiq-otel-collector
elif systemctl list-unit-files | grep -q bindplane-agent; then
  systemctl enable bindplane-agent
  systemctl restart bindplane-agent
fi

systemctl list-units --type=service | grep -E 'bindplane|observiq|otel' || true

echo "===== Bindplane Dataplane startup completed ====="
SCRIPT
}
