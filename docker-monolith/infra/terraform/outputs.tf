output "docker_ip" {
  value = yandex_compute_instance.docker[*].network_interface.0.nat_ip_address
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tmpl",
 {
  docker_ip = yandex_compute_instance.docker[*].network_interface.0.nat_ip_address,
 }
 )
 filename = "../ansible/inventory.json"
}
