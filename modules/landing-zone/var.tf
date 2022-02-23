variable "env" {
  default   = "dev"
  sensitive = false
}

variable "location" {
  default   = "East US 2"
  sensitive = false
}

variable "app_name" {
  type      = string
  sensitive = false
}

variable "github_organization_name" {
  type        = string
  sensitive   = true
  description = "The name of the GitHub Organiztion that will contain the workload's Repo."
}

variable "github_repo_name" {
  type        = string
  sensitive   = true
  description = "The name of the GitHub Repo that will host the workload that will be deployed to the Azure Landing Zone."
}

variable "github_bind_object" {
  type        = string
  sensitive   = true
  description = "The GitHub branch or environment to which the federation is bound."
  default     = "environment:dev"
}

variable "remote_state_storage_default_action" {
  type        = string
  default     = "Allow"
  sensitive   = true
  description = "The Default Network posture of the remote state Storage Account."
}

variable "remote_state_storage_ip_rules" {
  type        = list(any)
  default     = []
  sensitive   = true
  description = "The list of IP's to allow to access the remote state Storage Account."
}

variable "admin_user_principal_name" {
  type        = string
  sensitive   = true
  description = "The user principal name of the admin for the app."
}