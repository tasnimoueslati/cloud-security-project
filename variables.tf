# variables.tf
variable "resource_group_name" {
  default = "rg-security-project"
}
variable "location" {
  default = "France Central"
}
variable "alert_email" {
  type = string
}

