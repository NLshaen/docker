# Project to deploy GLPI with docker

# Table of Contents
1. [Introduction](#introduction)
2. [Deploy CLI](#deploy-with-CLI)
    - [Deploy GLPI without database](#deploy-glpi-without-database)
    - [Deploy GLPI with existing database](#deploy-glpi-with-existing-database)
3. [Deploy docker-compose](#deploy-with-docker-compose)
4. [Environnment variables](#environnment-variables)
    - [Timezone](#timezone)

# Introduction

Install and run an GLPI instance with docker.

# Deploy with CLI

## Deploy GLPI without database
```sh
docker run --name glpi -p 80:80 -d lpcbc/glpi:9.2.3 /bin/bash
```

## Deploy GLPI with existing database
```sh
docker run --name glpi --link yourdatabase:mysql -p 80:80 -d lpcbc/glpi:9.2.3 /bin/bash
```

## Deploy GLPI with database and persistance container data

For an usage on production environnement or daily usage, it's recommanded to use a data container for persistent data.

```

Enjoy :)

# Deploy with docker-compose

To deploy with docker compose, you use *docker-compose.yml* and *mysql.env* file.
You can modify **_mysql.env_** to personalize settings like :

* MySQL root password
* GLPI database
* GLPI user database
* GLPI user password

To deploy, just run the following command on the same directory as files

```sh
docker-compose up -d 
```

# Environnment variables

## TIMEZONE
If you need to set timezone for Apache and PHP

From commande line
```sh
docker run --name glpi --hostname glpi --link mysql:mysql --volumes-from glpi-data -p 80:80 --env "TIMEZONE=Europe/Brussels" -d lpcbc/glpi:9.2.3
```

From docker-compose

Modify this settings
```yml
environment:
     TIMEZONE=Europe/Brussels
```
