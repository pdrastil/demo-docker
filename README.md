# Docker demo application

This repository contains sample Docker container with web application running on port 8080.

## Image details

- Alpine 3.11
- Oracle Java 8
- Java web application

## Usage

To test sample web application run following commands

```sh
$ ID=$(docker run -d -p 8080:8080 pdrastil/hello-world:1.0)
$ curl localhost:8080
$ docker kill $ID
```

## How to build

Use `make` or reproduce the `docker build` commands from `Makefile`
