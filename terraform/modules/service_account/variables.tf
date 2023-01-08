variable "name_service_account_sa" {
  default = null
  type = string
}
variable "name_service_account_ingress" {
  default = null
  type = string
}
variable "folder_id" {
  default = null
  type = string
}
variable "member_ingress" {
  default = null
  type = list(string)
}