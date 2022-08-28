# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1g4u3sfpchj6i21hp7f"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gjl0488dbj7totafg8"
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
#variable "centos-7-base" {
#  default = "fd84756mb8sn06j43dpj"
#}

variable "public_key" {
  default = "key_value"
}
