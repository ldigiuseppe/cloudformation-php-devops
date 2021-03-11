# Docker Compose Laravel LEMP Stack & AWS ECS Cluster

In this repository you will find a docker-compose file with a LEMP stack to start with Laravel as a Framework.
This repository contains a little `docker-compose` configuration to start a `LEMP (Linux, Nginx, MariaDB, PHP)` stack locally.

## Details

The following versions are used.

* PHP 7.4 (FPM)
* Nginx
* MySql 5.7

## Configuration

You need to create the `.env` file and configure the variables:

```mv .env.example .env```

| Key | Description |
|-----|-------------|
|APP_NAME|The name used when creating a container.|
|DB_DATABASE|The MySQL database name used when creating the container.|
|DB_PASSWORD|The MySQL root password used when creating the container.|

## Usage

Create the containers:
```docker-compose up -d```

Go to http://localhost

You can execute artisan commands the following way:
```docker-compose exec php php artisan migrate```

## AWS CloudFormation Stack

Configure `.aws/config` environments and execute
```
bash ./create_stack.sh
```

jq is needed for the script to work