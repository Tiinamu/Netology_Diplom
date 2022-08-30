## Дипломное задание по курсу «DevOps-инженер»

__Дипломный практикум в YandexCloud__

*Цели:*

1.	Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2.	Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3.	Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4.	Настроить кластер MySQL.
5.	Установить WordPress.
6.	Развернуть Gitlab CE и Gitlab Runner.
7.	Настроить CI/CD для автоматического развёртывания приложения.
8.	Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

*Этапы выполнения:*

__1. Регистрация доменного имени__

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.
ПРИМЕЧАНИЕ: Далее в качестве примера используется домен you.domain замените его вашим доменом.
Рекомендуемые регистраторы:

• nic.ru

• reg.ru

*Цель:*

1.	Получить возможность выписывать TLS сертификаты для веб-сервера.

*Ожидаемые результаты:*

1.	У вас есть доступ к личному кабинету на сайте регистратора.
2.	Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

*Решение:*

Зарегистрировано доменное имя tiinamu.ru в регистраторе доменных имен REG.RU

![d_1](pictures/d_1.JPG) 

__2. Создание инфраструктуры__

Для начала необходимо подготовить инфраструктуру в YC при помощи Terraform.

*Особенности выполнения:*

•	Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;

•	Следует использовать последнюю стабильную версию Terraform.

*Предварительная подготовка:*

1.	Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2.	Подготовьте backend для Terraform:
а. Рекомендуемый вариант: Terraform Cloud
б. Альтернативный вариант: S3 bucket в созданном YC аккаунте.
3.	Настройте workspaces
а. Рекомендуемый вариант: создайте два workspace: stage и prod. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.
б. Альтернативный вариант: используйте один workspace, назвав его stage. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (default).
4.	Создайте VPC с подсетями в разных зонах доступности.
5.	Убедитесь, что теперь вы можете выполнить команды terraform destroy и terraform apply без дополнительных ручных действий.
6.	В случае использования Terraform Cloud в качестве backend убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

*Цель:*

1.	Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
2.	Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

*Ожидаемые результаты:*

1.	Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2.	Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

*Решение:*

2.1) 	Настройка ключей:

2.1.1)	Сгенерим ключи в директории .ssh:
```
artem@ubuntu:~/.ssh$ ssh-keygen -t rsa
```
![d_2](pictures/d_2.JPG) 

2.1.2)	Скопируем публичный ключ в authorized_keys

![d_3](pictures/d_3.JPG) 

2.1.3)	Создадим файлик с ключом для сервисного аккаунта: key.json:
```
yc iam key create --service-account-name my-robot --output key.json

artem@ubuntu:~/Netology_Diplom/terraform$ cat key.json 
{
   "id": "ajej61vkuh38h60fn6qb",
   "service_account_id": "aje10prv6nj8qjr5roku",
   "created_at": "2022-08-15T14:16:04.292449158Z",
   "key_algorithm": "RSA_2048",
   "public_key": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzdajAMBNf19nqiYeQoaV\nG/8cWI6pXwitOYyPwwXDMuB/LeN1KPQaqPQQAx9Yvd9IKZXgj9lMXXJRmhTsEMCV\nMalSPyjNZQ3YSUOkl0DnPUecLy24/DPgU7GBm3MH/WIFFeiOmFc83yFncD2jha8a\nEY/MAGQ6hEPHPeQNGolVmoijXutfw9kKtUCCbs3d2RTVqcJd6WGRDWPDhWV3C/MG\nEfJ9nk4Z8k58f7nvRA3hW1eSmRYfL0Ew6nsegHp9qTXU6HOCWJBFfMRXDDYJEYbx\ncjCGmn1VS/9bz9gWD4vwMuzOkCZ5hJdRu/bihbAJMPgDejuMB1L7h/zNAPEnXesM\nGQIDAQAB\n-----END PUBLIC KEY-----\n",
   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDN1qMAwE1/X2eq\nJh5ChpUb/xxYjqlfCK05jI/DBcMy4H8t43Uo9Bqo9BADH1i930gpleCP2UxdclGa\nFOwQwJUxqVI/KM1lDdhJQ6SXQOc9R5wvLbj8M+BTsYGbcwf9YgUV6I6YVzzfIWdw\nPaOFrxoRj8wAZDqEQ8c95A0aiVWaiKNe61/D2Qq1QIJuzd3ZFNWpwl3pYZENY8OF\nZXcL8wYR8n2eThnyTnx/ue9EDeFbV5KZFh8vQTDqex6Aen2pNdToc4JYkEV8xFcM\nNgkRhvFyMIaafVVL/1vP2BYPi/Ay7M6QJnmEl1G79uKFsAkw+AN6O4wHUvuH/M0A\n8Sdd6wwZAgMBAAECggEAST2A/Ghwaszwnts3UyZ98dtBI8WHQHhe4qZAFP186iJ1\nPke7zVmmDs3g0KubsNu82ocowyZnhKyDmpatNHzB2UzNJgoHo1hcyBzYeLUwUl6j\nlSnos1xmCoGTg1NX2XHCK3x3GH+Z+i7xlj9oas3WMb9/r/f51kwjncMCYpnRKs2l\nuHNIBaLPaikGENkytzdmRMxVltp21dCT4QQbvBLKSaROZJ74GvJ1sKO/h61uW+y3\n6jVlJz7MZL0LUbjM1UG1W9/IQRj3MbbcSQqibH1KnwrS9yy+vvku8W4AHavXHA0b\n0dn8aAPUHjpbw6K+G36i72u4ljok9rrPAxg3r4Q+LQKBgQDU2XWpidZHxcIzprWt\nbzEMSOVBPdibwc/fy8BDizYQQO0LOgX+qEB6XBQNeNDD2N99cloJLN+QwDJxFP6y\nTcRqjecSjTwrdsIGLTqe/coioMbnel7SZZJfjTDgGxUjLGamrqty8N3wUBWLfX3L\nRfoxY2X4kfRPC6yLfiCY4rPojwKBgQD3kVDzo7BCi86Io1NgkgC1c2kDeRyVyDVW\ngaVTHjbYzrLH4/nNY5sPVXvr7A2L5Cm44W0VREiqTZiLAX+9i8jy2ZNRj8qeaasV\nVmR+CLf0TggrE0GFhufJw9hMlaVlB8uM28NY2PMt3gaqdIjGTuJ69G614ChOyczI\nvb40FweE1wKBgFWG4+6yAjZo0nYqwMnl6hGDoQssLMO5hyvoFWOOprS1QgrGz+3Z\n8b65DR20tD5eAL/JmUAildr2P86MnyNKeGhQiM89jTXxzFjrB6knVXfAnuwYkc19\nHuniNAd5Gm89wimr+hx/iM6tf1rDnC53+eaqiCjvjPnOORD8J2EHhz8lAoGATplV\nUTUL9eS7OshX5VYVYYZ1tcOS3r8EqCVbHst98FGXkzz/B0VzamfigyGbn2leEbOI\nVXMret5N6vwb2UrzDp8jVYbIdojn50tZdmZAORE5KKvhZopRNs618oKkUzIpXtw6\n5g9jDZHrHd0Hu6Y5432NVLMJORJ6sNUE+TbCjVsCgYBgU5SUa8Yz/f/No5XbombL\njrHfv0K/swLtvUEGYM6tfnFpybDUoi2QK9lqLjcH5US692OVkmQF0qOYkxv8MFUt\nS8wN6FH0goBYM/5JdmYaz9MjyewWoZt3WDLHnW+sm9tzaWbSrEGAYX/rfbR8di77\nSb841G7C3OWT+MwoenOqqQ==\n-----END PRIVATE KEY-----\n"
```

2.1.4)	Зададим права
```
artem@ubuntu:~/.ssh$ chmod 700 ~/.ssh
artem@ubuntu:~/.ssh$ chmod 600 ~/.ssh/*
```

2.2)	Создадим backet в Yandex Cloud

Для того, чтобы не пользоваться консолью Yandex Cloud при создании bucket-а, я создал еще один проект terraform-а, чтобы через него создать бакет.

Содержание файла terraform /main.tf для создания бакета:
```
provider "yandex" {
  cloud_id  = "b1g4u3sfpchj6i21hp7f"
  folder_id = "b1gjl0488dbj7totafg8"
  zone      = "ru-central1-a"
  service_account_key_file = "key.json"
}

resource "yandex_storage_bucket" "test" {
  access_key = "YCAJEe1qfB6ng9cSWti6Q0wzD"
  secret_key = "YCM1LJ8lBvph0T4j43juSJu0FBdJk1tuXOg0-UDv"
  bucket = "tiinamu-bucket"
}
```

2.3)	Проверим, кому какие роли назначены на каталог netology-tiinamu-new
```
artem@ubuntu:~/Netology_7_3_Terraform/terraform$ yc resource-manager folder list-access-bindings netology-tiinamu-new
+---------+----------------+-----------------------+
| ROLE ID |  SUBJECT TYPE  |      SUBJECT ID       |
+---------+----------------+-----------------------+
| editor  | system         | allAuthenticatedUsers |
| editor  | serviceAccount | aje10prv6nj8qjr5roku  |
| admin   | system         | allAuthenticatedUsers |
+---------+----------------+-----------------------+
```

2.4)	Посмотрим сервисный аккаунт:
```
artem@ubuntu:~/Netology_7_3_Terraform/terraform$ yc iam service-account list
+----------------------+----------+
|          ID          |   NAME   |
+----------------------+----------+
| aje10prv6nj8qjr5roku | my-robot |
+----------------------+----------+
```

2.5)	Для сервисной учетной записи my-robot получим значения access-key и secret_key, чтобы потом применить их в main.tf при создании бакета:
```
artem@ubuntu:~/Netology_7_3_Terraform/terraform$ yc iam access-key create --service-account-name my-robot
access_key:
  id: ajessoov9fp8d9d2ag15
  service_account_id: aje10prv6nj8qjr5roku
  created_at: "2022-07-28T19:57:52.087942940Z"
  key_id: YCAJEe1qfB6ng9cSWti6Q0wzD
secret: YCM1LJ8lBvph0T4j43juSJu0FBdJk1tuXOg0-UDv

There is a new yc version '0.93.0' available. Current version: '0.91.0'.
See release notes at https://cloud.yandex.ru/docs/cli/release-notes
You can install it by running the following command in your shell:
	$ yc components update
```

2.6)	Создадим два worspace 
```
artem@ubuntu:~/Netology_7_3_Terraform/terraform$ sudo terraform workspace new prod
artem@ubuntu:~/Netology_7_3_Terraform/terraform$ sudo terraform workspace new stage
```

Проверим:
```
artem@ubuntu:~/Netology_7_3_Terraform/terraform$ terraform workspace list
  default
  prod
* stage
```

2.7)	Запустим тестовый проект terraform для создания бакета через консоль:
```
artem@ubuntu:~/Netology_7_3_test/terraform$ sudo terraform init
artem@ubuntu:~/Netology_7_3_test/terraform$ sudo terraform plan
artem@ubuntu:~/Netology_7_3_test/terraform$ sudo terraform apply
```
В в YC создастся бакет tiinamu-bucket.
![d_4](pictures/d_4.JPG) 

2.8)	Далее настраиваем рабочий проект artem@ubuntu:~/Netology_Diplom/terraform$ (меняем имена сети и подсети, добавим двойку в суффикс, чтобы имена не пересекались с сетью и подсетью, используемые при создании бакета).

Создаем файлы проекта terraform (key.json создан ранее):

![d_5](pictures/d_5.JPG) 

2.9)	Запуск боевого terraform-а:
```
artem@ubuntu:~/Netology_Diplom/terraform$ terraform init
artem@ubuntu:~/Netology_Diplom/terraform$ terraform apply
```

2.10)	В UI Yandex Cloud видим, что ВМ создались (по итогам проекта):

![d_6](pictures/d_6.JPG) 

![d_7_1](pictures/d_7_1.PNG) 

2.11)	DNS-серверы оставил от REG.RU

![d_8](pictures/d_8.JPG)

2.12)	Для того, чтобы каждый разе не перенаправлять А-записи на новый публичный адрес сервера, играющего роль revers-proxy, я арендовал один публичный адрес на Yandex Cloud:

![d_8_5](pictures/d_8_5.JPG)

2.13)	Настроим А-записи в REG.RU:

![d_9_1](pictures/d_9_1.PNG)

2.14)	Проверим подключение к серверу с ролью reverse-proxy – nginx.tiinamu.ru

Закинем публичный ключ на виртуальную машину в Yandex Cloud
```
artem@ubuntu:~/Netology_Diplom/terraform$ ssh-copy-id ubuntu@51.250.73.164
```
Подключение к машине:
```
artem@ubuntu:~/Netology_Diplom/playbook_test4$ ssh ubuntu@51.250.73.164
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-112-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 * Canonical Livepatch is available for installation.
   - Reduce system reboots and improve kernel security. Activate at:
     https://ubuntu.com/livepatch
New release '20.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.



#################################################################
This instance runs Yandex.Cloud Marketplace product
Please wait while we configure your product...

Documentation for Yandex Cloud Marketplace images available at https://cloud.yandex.ru/docs

#################################################################

Last login: Sun Aug 28 14:44:38 2022 from 138.199.21.207
ubuntu@tiinamu:~$
```

*Вывод:*

Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.

__3. Установка Nginx и LetsEncrypt__

Необходимо разработать Ansible роль для установки Nginx и LetsEncrypt.
Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь тестовыми сертификатами, так как количество запросов к боевым серверам LetsEncrypt лимитировано.

*Рекомендации:*

• Имя сервера: you.domain
• Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

*Цель:*

1.	Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.

*Ожидаемые результаты:*

1.	В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
•	https://www.you.domain (WordPress)
•	https://gitlab.you.domain (Gitlab)
•	https://grafana.you.domain (Grafana)
•	https://prometheus.you.domain (Prometheus)
•	https://alertmanager.you.domain (Alert Manager)
3.	Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!

*Решение:*

3.1)	Подготовим Playbook для сервера с ролью reverse-proxy – nginx.tiinamu.ru
Создадим следующую структуру каталогов и файлов (наполнение файлов ниже):
```
artem@ubuntu:~/Netology_Diplom/playbook_test4$ tree
.
├── ansible.cfg
├── inventory
├── provision.yml
└── roles
    └── nginx-role
        ├── defaults
        │   └── main.yml
        ├── handlers
        │   └── main.yml
        ├── tasks
        │   ├── cli.ini
        │   ├── letsencrypt.yml
        │   └── main.yml
        └── templates
            ├── default.conf
            └── http_301.j2
            └── http.j2
            └── https.j2
            └── nginx-html-index.j2
```
Далее с каждой вновь создаваемой машиной – дописываем хосты в inventory, дополняем roles соответствующими ролями и добавляем таски в provision.yml

3.2)	Запускаем playbook:
```
artem@ubuntu:~/Netology_Diplom/playbook_test4$ ansible-playbook –i inventory provision.yml
```
Ролью nginx-role разворачиваем на основе nginx reverse-proxy, с помощью утилиты certbot в центре сертификации letsencrypt получаем сертификаты и подставляем их в /etc/nginx/sites-enabled/default и /etc/nginx/sites-available/default

После рестарта nginx, можем с браузера по доменному имени через https зайти на сайт и посмотреть сертификат:
```
ubuntu@vm:/etc/nginx$ sudo nginx -s reload
```
![d_10](pictures/d_10.JPG)

__4. Установка кластера MySQL__

Необходимо разработать Ansible роль для установки кластера MySQL.
Рекомендации:
• Имена серверов: db01.you.domain и db02.you.domain
• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1.	Получить отказоустойчивый кластер баз данных MySQL.

*Ожидаемые результаты:*

1.	MySQL работает в режиме репликации Master/Slave.
2.	В кластере автоматически создаётся база данных c именем wordpress.
3.	В кластере автоматически создаётся пользователь wordpress с полными правами на базу wordpress и паролем wordpress.
Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!

*Решение:*

4.1)	Добавим ВМ-ы через terraform 
```
artem@ubuntu:~/Netology_Diplom2/terraform$ terraform apply -target=yandex_compute_instance.mysql1
artem@ubuntu:~/Netology_Diplom2/terraform$ terraform apply -target=yandex_compute_instance.mysql2
```

4.2)	Дополним Playbook ролью mysql-role, добавим tasks, дополним inventory и provision.yml

4.3)	Зайдем на сервер mysql1.tiinamu.ru, проверим корректность запущенной службы:

![d_11](pictures/d_11.JPG)

4.4)	Проверим, что создалась БД wordpress:

![d_12](pictures/d_12.JPG)

4.5)	На mysql2.tiinamu.ru действия аналогичные.

__5. Установка WordPress__

Необходимо разработать Ansible роль для установки WordPress.

*Рекомендации:*

• Имя сервера: app.you.domain

• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1.	Установить WordPress. Это система управления содержимым сайта (CMS) с открытым исходным кодом.
По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

*Ожидаемые результаты:*

1.	Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).
2.	В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy: https://www.you.domain (WordPress)
3.	На сервере you.domain отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
В браузере можно открыть URL https://www.you.domain и увидеть главную страницу WordPress.

*Решение:*

5.1)	Добавим ВМ через terraform 
artem@ubuntu:~/Netology_Diplom2/terraform$ terraform apply -target=yandex_compute_instance.wordpress

5.2)	Дополним Playbook ролью mysql-role, добавим tasks, дополним inventory и provision.yml

5.3)	Проверим в браузере, как открывается URL https://www.tiinamu.ru

![d_13](pictures/d_13.PNG)

__6. Установка Gitlab CE и Gitlab Runner__

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

*Рекомендации:*

• Имена серверов: gitlab.you.domain и runner.you.domain

• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1.	Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер app.you.domain при коммите в репозиторий с WordPress.
Подробнее о Gitlab CI

*Ожидаемый результат:*

1.	Интерфейс Gitlab доступен по https.
2.	В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
•	https://gitlab.you.domain (Gitlab)
3.	На сервере you.domain отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
4.	При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

*Решение:*

6.1)	Добавим ВМ через terraform: 
```
artem@ubuntu:~/Netology_Diplom2/terraform$ terraform apply -target=yandex_compute_instance.gitlab
artem@ubuntu:~/Netology_Diplom2/terraform$ terraform apply -target=yandex_compute_instance.runner
```

6.2)	Дополним Playbook ролями gitlab-role, runner-role, добавим соответствующие tasks, дополним inventory и provision.yml
Для доступа на gitlab.tiinamu.ru – {root/EgT2vcmVW!ql1}. К runner подключение автоматически через gitlab_runner_token: "GR1348741mwxxg9ekV2nEgT2vcmVW"

6.3)	Проверим в браузере, как открывается URL https://gitlab.tiinamu.ru

![d_14](pictures/d_14.JPG)

![d_15](pictures/d_15.JPG)

![d_16](pictures/d_16.JPG)

6.4) Создадим тестовый проект в gitlab-е  test_wordpress

![d_16_1](pictures/d_16_1.PNG)

Создадим .gitlab-ci.yml, закоммитим. 
Добавим ssh-key в Settings/CI/CD/Variables

![d_16_2](pictures/d_16_2.PNG)

Скорректируем аттрибут wp-block-post-title на главной странице проекта. 
При commit в проект запускается deploy-job и изменения выливаются на сервер:

![d_16_3](pictures/d_16_3.PNG)

__7. Установка Prometheus, Alert Manager, Node Exporter и Grafana__

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

*Рекомендации:*

• Имя сервера: monitoring.you.domain

• Характеристики: 4vCPU, 4 RAM, Internal address.

*Цель:*

1.	Получение метрик со всей инфраструктуры.

*Ожидаемые результаты:*

1.	Интерфейсы Prometheus, Alert Manager и Grafana доступны по https.
2.	В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:

• https://grafana.you.domain (Grafana)

• https://prometheus.you.domain (Prometheus)

• https://alertmanager.you.domain (Alert Manager)

3.	На сервере you.domain отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
4.	На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
5.	У Alert Manager есть необходимый набор правил для создания алертов.
6.	В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
7.	В Grafana есть дашборд отображающий метрики из MySQL (*).
8.	В Grafana есть дашборд отображающий метрики из WordPress (*).

*Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.*

*Решение:*

Принцип мониторинга будет следующий:

![d_17](pictures/d_17.JPG)

7.1)	Добавим ВМ через terraform: 
```
artem@ubuntu:~/Netology_Diplom2/terraform$ terraform apply -target=yandex_compute_instance.monitoring
```

7.2)	Дополним Playbook ролями alertmanager-role, prometheus-role, grafana-role, node_exporter-role, добавим соответствующие tasks, дополним inventory и provision.yml

7.3) 	После установки node exporter на каждом сервере проверим корректность запуска службы (ниже пример для сервера nginx):

![d_18](pictures/d_18.JPG)

7.4)	Проверим доступность серверов по порту 9100, чтобы собирать метрики через Node exporter:

![d_19](pictures/d_19.JPG)

7.5)	Проверим в браузере, как открывается URL https://prometheus.tiinamu.ru

![d_20_1](pictures/d_20_1.PNG)

7.6)	Проверим в браузере, как открывается URL https://alertmanager.tiinamu.ru

![d_21](pictures/d_21.JPG)

7.7)	Если зайти на сервер мониторинга по порту 9100, то можно посмотреть всем метрики, которые собираются

![d_22](pictures/d_22.JPG)

7.8)	Проверим в браузере, как открывается URL https://grafana.tiinamu.ru

![d_23](pictures/d_23.JPG)

![d_24](pictures/d_24.JPG)

![d_25](pictures/d_25.JPG)

Репозитории с манифестами Terraform, Ansible находятся здесь: 
https://github.com/Tiinamu/Netology_Diplom.git 

