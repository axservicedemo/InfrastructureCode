variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}
variable "subscription_id" {
  description = "The Azure Secret"
}
variable "tenant_id" {
  description = "The Azure Secret"
}
variable "client_secret" {
  description = "The Azure Secret"
}
variable "client_id" {
  description = "The Azure Secret"
}
# variable "image_name" {
#   default = "demo-centos-image-18-09-2020"
#   description = "The Custom image Name"
# }
variable "location" {
  description = "The region which the resource is deployed"
}
variable "application_port" {
  default = 80
  description = "The LB port where the application is configured"
}
variable "subnet_id" {
  description = "The subnet ID in which the resources needs to be deployed"
}
# variable "resources_predefined_rg" {
#   description = "The resource group where the images has be located"
# }