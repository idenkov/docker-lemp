# LEMP Dockerized - 1rw

> Dockerized PHP development stack: Nginx, PHP-FPM on one image(currently building from dockerfile) and PHP-FPM and Redis images


## Requirements

* [Docker Engine](https://docs.docker.com/installation/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Machine](https://docs.docker.com/machine/) (Mac and Windows only)

## Running

Set up a Docker Machine and then run:

```
$ docker-compose up
```

##Folders

* SQL - At first start the Percona container will take any .sql.gz files and import into the default DB specified in docker-compose.yml
* logs - Access and error logs from nginx
* conf - Configuration for the different services, links/cpy/volumes defined ind dockerfile and docker-compose.yml
* sites - nginx sites/vhosts config, currently lb was just for testing
* www - web root

