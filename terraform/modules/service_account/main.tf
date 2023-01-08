resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name        = var.name_service_account_sa
}
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}
#Создаём сервисный аккаунт и выдаём права
resource "yandex_iam_service_account" "ingress" {
  folder_id = var.folder_id
  name        = var.name_service_account_ingress
}
resource "yandex_resourcemanager_folder_iam_member" "alb_editor" {
  folder_id = var.folder_id
  for_each = toset(var.member_ingress)
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.ingress.id}"
}
# Роль alb.editor нужна для создания балансировщиков
# resource "yandex_resourcemanager_folder_iam_member" "alb_editor" {
#   folder_id = var.folder_id
#   role      = "alb.editor"
#   member    = "serviceAccount:${yandex_iam_service_account.ingress.id}"
# }
# # Роль vpc.publicAdmin нужна для управления внешними адресами
# resource "yandex_resourcemanager_folder_iam_member" "vpc_publicAdmin" {
#   folder_id = var.folder_id
#   role      = "vpc.publicAdmin"
#   member    = "serviceAccount:${yandex_iam_service_account.ingress.id}"
# }
# # нужна для скачивания сертификатов из Yandex Certificate Manager
# resource "yandex_resourcemanager_folder_iam_member" "certificate_manager" {
#   folder_id = var.folder_id
#   role      = "certificate-manager.certificates.downloader"
#   member    = "serviceAccount:${yandex_iam_service_account.ingress.id}"
# }
# # Роль compute.viewer нужна для добавления нод в балансировщик
# resource "yandex_resourcemanager_folder_iam_member" "compute_viewer" {
#   folder_id = var.folder_id
#   role      = "compute.viewer"
#   member    = "serviceAccount:${yandex_iam_service_account.ingress.id}"
# }

resource "yandex_iam_service_account_key" "ingress" {
  service_account_id = "${yandex_iam_service_account.ingress.id}"
  key_algorithm      = "RSA_4096"
}