variable "env" {
  type        = string
  sensitive   = false
  description = "The environment the resources will represent."
  default     = "dev"
}

variable "location" {
  type        = string
  sensitive   = false
  description = "The Azure Region to which the resources will be deployed."
  default     = "East US 2"
}

variable "app_name" {
  type        = string
  sensitive   = false
  description = "The name of the application or workload these resources will represent."
}

variable "tags" {
  type        = map(string)
  sensitive   = false
  description = "The set of tags to apply to the resources."
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
  sensitive   = true
  description = "The Default Network posture of the remote state Storage Account."
  default     = "Allow"
}

variable "remote_state_storage_ip_rules" {
  type        = list(any)
  sensitive   = true
  description = "The list of IP's to allow to access the remote state Storage Account."
  default     = []
}

variable "admin_user_principal_name" {
  type        = string
  sensitive   = true
  description = "The user principal name of the admin for the app."
}

variable "deployer_group_assignments" {
  type = list(string)
  sensitive = true
  description = "The Object ID of the other Azure AD Groups to which the Deployer Service Principal is assigned."
}