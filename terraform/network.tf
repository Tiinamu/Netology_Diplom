# Network
resource "yandex_vpc_network" "default" {
  name = "net2"
}

resource "yandex_vpc_subnet" "default" {
  name           = "subnet2"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}

resource "yandex_vpc_route_table" "route-table" {
  name = "route-table"
  network_id = "${yandex_vpc_network.default.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.101.5"
  }
}

resource "yandex_vpc_subnet" "default-nat" {
  name           = "subnet-nat"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  route_table_id = yandex_vpc_route_table.route-table.id
  v4_cidr_blocks = ["192.168.102.0/24"]
}
