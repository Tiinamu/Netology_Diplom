provider "yandex" {
  cloud_id  = "b1g4u3sfpchj6i21hp7f"
  folder_id = "b1gjl0488dbj7totafg8"
  zone      = "ru-central1-a"
  service_account_key_file = "key.json"
}


terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "tiinamu-bucket"
    region     = "ru-central1"
    key        = "bucket_path/terraform.tfstate"
    access_key = "YCAJEe1qfB6ng9cSWti6Q0wzD"
    secret_key = "YCM1LJ8lBvph0T4j43juSJu0FBdJk1tuXOg0-UDv"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "yandex_compute_image" "nat-image" {
  family = "nat-instance-ubuntu"
}

# создание VM Nginx
resource "yandex_compute_instance" "nginx" {
  name                      = "nginx"
  zone                      = "ru-central1-a"
  hostname                  = "tiinamu.ru"
  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${data.yandex_compute_image.nat-image.id}"
      name        = "root-nginx"
      type        = "network-nvme"
      size        = 10
    }
  }

  network_interface {
    subnet_id      = "${yandex_vpc_subnet.default.id}"
    ip_address     = "192.168.101.5"
    nat            = true
    nat_ip_address = "51.250.73.164"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
  }
}

#создадим VM Nginx
#resource "yandex_compute_instance" "nginx" {
#  name                      = "nginx"
#  zone                      = "ru-central1-a"
#  hostname                  = "tiinamu.ru"
#  allow_stopping_for_update = true

#  lifecycle {
#    create_before_destroy = true
#  }

#  resources {
#    cores  = 2
#    memory = 2
#  }

#  boot_disk {
#    initialize_params {
#      image_id    = "${yandex_compute_image.image.id}"
#      name        = "root-nginx"
#      type        = "network-nvme"
#      size        = 10
#    }
#  }

#  network_interface {
#    subnet_id      = "${yandex_vpc_subnet.default.id}"
#    ip_address     = "192.168.101.5"
#    nat            = true
#    nat_ip_address = "51.250.73.164"
#  }

#  metadata = {
#    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
#  }
#}

resource "yandex_compute_image" "image" {
  source_family = "ubuntu-2004-lts"
}

#создадим VM MySQL1
resource "yandex_compute_instance" "mysql1" {
  name                      = "mysql1"
  zone                      = "ru-central1-a"
  hostname                  = "mysql1.tiinamu.ru"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${yandex_compute_image.image.id}"
      name        = "root-mysql1"
      type        = "network-nvme"
      size        = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default-nat.id}"
    ip_address  = "192.168.102.6"
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
  }
}

#создадим VM MySQL2
resource "yandex_compute_instance" "mysql2" {
  name                      = "mysql2"
  zone                      = "ru-central1-a"
  hostname                  = "mysql2.tiinamu.ru"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${yandex_compute_image.image.id}"
      name        = "root-mysql2"
      type        = "network-nvme"
      size        = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default-nat.id}"
    ip_address  = "192.168.102.7"
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
  }
}

#создадим VM WordPress
resource "yandex_compute_instance" "wordpress" {
  name                      = "wordpress"
  zone                      = "ru-central1-a"
  hostname                  = "wordpress.tiinamu.ru"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${yandex_compute_image.image.id}"
      name        = "root-wordpress"
      type        = "network-nvme"
      size        = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default-nat.id}"
    ip_address  = "192.168.102.8"
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
  }
}


#создадим VM Gitlab
resource "yandex_compute_instance" "gitlab" {
  name                      = "gitlab"
  zone                      = "ru-central1-a"
  hostname                  = "gitlab.tiinamu.ru"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${yandex_compute_image.image.id}"
      name        = "root-gitlab"
      type        = "network-nvme"
      size        = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default-nat.id}"
    ip_address  = "192.168.102.9"
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
  }
}

#создадим VM Runner
resource "yandex_compute_instance" "runner" {
  name                      = "runner"
  zone                      = "ru-central1-a"
  hostname                  = "runner.tiinamu.ru"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${yandex_compute_image.image.id}"
      name        = "root-runner"
      type        = "network-nvme"
      size        = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default-nat.id}"
    ip_address  = "192.168.102.10"
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
  }
}

#создадим VM Monitoring
resource "yandex_compute_instance" "monitoring" {
  name                      = "monitoring"
  zone                      = "ru-central1-a"
  hostname                  = "monitoring.tiinamu.ru"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${yandex_compute_image.image.id}"
      name        = "root-monitoring"
      type        = "network-nvme"
      size        = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default-nat.id}"
    ip_address  = "192.168.102.11"
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/artem/.ssh/id_rsa.pub")}"
  }
}
