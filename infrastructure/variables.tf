#####################################
# GCP
#####################################

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type = string
}

#####################################
# Bindplane
#####################################

variable "bindplane_license" {
  type      = string
  sensitive = true
}

variable "bindplane_admin_user" {
  type = string
}

variable "bindplane_admin_password" {
  type      = string
  sensitive = true
}

variable "bindplane_port" {
  type    = number
  default = 3001
}

#####################################
# PostgreSQL
#####################################

variable "pg_user" {
  type    = string
  default = "bindplane"
}

variable "pg_password" {
  type      = string
  sensitive = true
}

variable "pg_database" {
  type    = string
  default = "bindplane"
}

variable "pg_sslmode" {
  type    = string
  default = "disable"
}


#####################################
# Data Plane
#####################################

variable "dataplane_count" {
  type    = number
  default = 2
}

variable "bindplane_control_url" {
  description = "Bindplane control plane URL"
  type        = string
}

variable "bindplane_agent_token" {
  description = "Bindplane agent enrollment token"
  type        = string
  sensitive   = true
}
