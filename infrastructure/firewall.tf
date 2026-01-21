resource "google_compute_firewall" "bindplane_ui" {
  name    = "allow-bindplane-ui-2"
  network = "default"

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["3001"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["bindplane"]
}
