variable "cluster_id" {
  default = null
  type = string 
}
variable "subnet_ids" {
  default = null
  type = string
}
variable "gce_ssh_user" {
  default = "mikhail"
  type = string
}
variable "gce_ssh_pub_key_file" {
  default = "~/.ssh/id_rsa.pub"
  type = string
}
variable "name_node" {
  default = null
  type = string 
}