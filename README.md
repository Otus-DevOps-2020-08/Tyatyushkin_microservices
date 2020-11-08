[![Build Status](https://travis-ci.com/Otus-DevOps-2020-08/Tyatyushkin_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2020-08/Tyatyushkin_microservices)

# Tyatyushkin_microservices
Tyatyushkin microservices repository

---

### Docker-3

#### Выполненные работы

1. Разбиваем наше приложение на несколько компонентов
2. Запускаем наше приложение
3. Оптимизируем наше приложение
4. Используем volume

#### Задания со ⭐
1. Запуск контенеров с другими алиасами и передача данных с помощью переменных.
```
docker run -d --network=reddit --network-alias=post_db_01 --network-alias=comment_db_01 mongo:latest
docker run -d --network=reddit -e POST_DATABASE_HOST=post_db_01 -e POST_DATABASE=posts_01 --network-alias=post_01 tyatyushkin/post:1.0 
docker run -d --network=reddit -e COMMENT_DATABASE_HOST=comment_db_01 -e ENV COMMENT_DATABASE=comments_01 --network-alias=comment_01 tyatyushkin/comment:1.0
docker run -d --network=reddit -e  POST_SERVICE_HOST=post_01 -e COMMENT_SERVICE_HOST=comment_01 -p 9292:9292 tyatyushkin/ui:1.0
```
2. Образ на основе alpine **Dockerfile.01**.
```
FROM alpine:3.6
RUN apk update --no-cache \
    && apk add --no-cache ruby ruby-dev ruby-bundler build-base \
    && gem install bundler --no-rdoc --no-ri \
    && rm -rf /var/cache/apk/*
```
собираем:
```
docker build -t tyatyushkin/ui:3.0 ./ui --file ui/Dockerfile.01
```
сравниваем:
```
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
tyatyushkin/ui        3.0                 f7d69fec86dc        16 seconds ago      205MB
tyatyushkin/ui        2.0                 987ce8d58d81        16 minutes ago      462MB
```

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
