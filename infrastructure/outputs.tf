############################################
# Control Plane Outputs
############################################

output "bindplane_control_public_ip" {
  description = "Public IP address of the Bindplane control plane VM"
  value       = google_compute_instance.bindplane_control.network_interface[0].access_config[0].nat_ip
}

output "bindplane_ui_url" {
  description = "Bindplane UI URL"
  value       = "http://${google_compute_instance.bindplane_control.network_interface[0].access_config[0].nat_ip}:${var.bindplane_port}"
}

############################################
# Dataplane Outputs
############################################

output "bindplane_dataplane_public_ips" {
  description = "Public IP addresses of Bindplane dataplane VMs"
  value = [
    for vm in google_compute_instance.bindplane_dataplane :
    vm.network_interface[0].access_config[0].nat_ip
  ]
}

output "bindplane_dataplane_instance_names" {
  description = "Instance names of Bindplane dataplane VMs"
  value = [
    for vm in google_compute_instance.bindplane_dataplane :
    vm.name
  ]
}
