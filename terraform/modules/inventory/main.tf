resource "local_file" "inventory" {
  content = templatefile("./data/templates/Inventory.tmpl",
  {
    prefix = "test"
    user = "mikhail"
    nodes = var.ip_instance.*
  }
  )
  filename = "../ansible/hosts"

}