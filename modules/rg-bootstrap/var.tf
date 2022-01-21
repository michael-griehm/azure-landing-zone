variable "env" {
  default = "dev"
  sensitive = false
}

variable "location" {
  default = "East US 2"
  sensitive = false
}

variable "app_name" {
  type = string
  sensitive = false
}