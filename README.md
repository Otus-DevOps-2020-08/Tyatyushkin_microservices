[![Build Status](https://travis-ci.com/Otus-DevOps-2020-08/Tyatyushkin_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2020-08/Tyatyushkin_microservices)

# Tyatyushkin_microservices
Tyatyushkin microservices repository

---
## Введение в Docker

#### Выполненные работы

1. Создаем репозиторий **docker-2**
2. Устанавливаем **docker** и **docker-tools**
3. Изучаем базовые команды
4. Создаем новый проект **docker**
5. Создаем там *docker-host* с помощью **docker-machine**
6. Работаем с **docker-hub**

#### Задания со ⭐

0. Описываем отличия в **docker-1.log**
1. Создаем 3 каталога: *ansible*, *packer*, *terraform*
2. Создаем playbook	 для раскатки docker в папке ansible: **install_docker.yml**
3. Создаем в каталоге packer **docker.json** где провиженором указываем ранее созданный playbook
4. Делаем build образа из **docker.json**
5. Создаем инфрастуктуру с помошью terraform с помощью нашего образа, добавив счетчик:
```
...
resource "yandex_compute_instance" "docker" {
  count = var.instances
  name  = "docker-${count.index}"
...
```
6. Модифицируем **outputs.tf** добавив туда формирование ивентори на базе шаблона
```
...
resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tmpl",
 {
  docker_ip = yandex_compute_instance.docker[*].network_interface.0.nat_ip_address,
 }
 )
 filename = "../ansible/inventory.json"
}
...
```
7. Создаем шаблон **inventory.tmpl**
```bash
#!/bin/bash

if [ "$1" == "--list" ] ; then
cat<<EOF
{
   "docker":
	${jsonencode({"hosts": [for docker_ip in docker_ip: "${docker_ip}"],
	})}
}
EOF
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
else
  echo "{ }"
fi
```
8. Далее настраваем ansible для работы с динамическим инвентори создав файлы **ansible.cgf** указав использование динамического инвентори
```
[defaults]
inventory = ./inventory.json
....

[inventory]
enable_plugins = script
...
```
9. Создаем **reddit.yml** для запуска нашего приложения в docker
```
---
- name: start reddit
  hosts: all
  become: true
  tasks:
  - name: install pip
    apt:
      name: python-pip
      state: latest
  - name: Install Docker Module for Python
    pip:
      name: docker
      executable: pip
  - name: start docker
    docker_container:
      name: reddit
      image: tyatyushkin/otus-reddit:1.0
      ports:
        - "9292:9292"
      state: started
      restart: yes

```
10. Раскатываем playbook и проверяем результаты.

---	
