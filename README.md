[azukiapp/mysql](http://images.azk.io/#/mysql)
==================

Base docker image to run a MySQL database server in [`azk`](http://azk.io)

MySQL versions (tags)
---

<versions>
- [`latest`,  `5.7`, `5`](https://github.com/azukiapp/docker-mysql/blob/master/5.7/Dockerfile)
- [`5.6`](https://github.com/azukiapp/docker-mysql/blob/master/5.6/Dockerfile)
- [`5.5`](https://github.com/azukiapp/docker-mysql/blob/master/5.5/Dockerfile)
</versions>

Image content use https://github.com/docker-library/mysql

### Usage with `azk`

Example of using this image with [azk](http://azk.io):

```js
/**
 * Documentation: http://docs.azk.io/Azkfile.js
 */

// Adds the systems that shape your system
systems({
  mysql: {
    // More info about mysql image: http://images.azk.io/#/mysql?from=azkfile-mysql-images
    image: {"docker": "azukiapp/mysql:5.7"},
    shell: "/bin/bash",
    wait: 25,
    mounts: {
      '/var/lib/mysql': persistent("mysql_data"),
      // to clean mysql data, run:
      // $ azk shell mysql -- rm -rf /var/lib/mysql/*
    },
    ports: {
      // exports global variables: "#{net.port.data}"
      data: "3306/tcp",
    },
    envs: {
      // set instances variables
      MYSQL_USER         : "azk",
      MYSQL_PASSWORD     : "azk",
      MYSQL_DATABASE     : "#{manifest.dir}_development",
      MYSQL_ROOT_PASSWORD: "azk",
    },
    export_envs: {
      // check this gist to configure your database
      // https://gist.github.com/gullitmiranda/62082f2e47c364ef9617
      DATABASE_URL: "mysql2://#{envs.MYSQL_USER}:#{envs.MYSQL_PASSWORD}@#{net.host}:#{net.port.data}/#{envs.MYSQL_DATABASE}",
      // or use splited envs:
      // MYSQL_USER    : "#{envs.MYSQL_USER}",
      // MYSQL_PASSWORD: "#{envs.MYSQL_PASSWORD}",
      // MYSQL_HOST    : "#{net.host}",
      // MYSQL_PORT    : "#{net.port.data}",
      // MYSQL_DATABASE: "#{envs.MYSQL_DATABASE}"
    },
  },
});
```

###### NOTE:

Do not forget to add `mysql` as a dependency of your application:

e.g.:

```js
systems({
  'my-app': {
    // Dependent systems
    depends: ["mysql"],
    /* ... */
  },
  'mysql': { /* ... */ }
})
```

### Usage with `docker`

To create the image `azukiapp/mysql`, execute the following command on the docker-mysql folder:

```sh
$ docker build -t azukiapp/mysql:5.7 5.7/
```

To run the image and bind to port 3306:

```sh
$ docker run --name mysql-server -d -p 3306:3306 azukiapp/mysql:5.7
```

The first time that you run your container, a new user `admin` with all privileges
will be created in MySQL with a random password. To get the password, check the logs
of the container by running:

Logs
---

```sh
# with azk
$ azk logs mysql

# with docker
$ docker logs mysql-server
```

Migrating an existing MySQL Server
----------------------------------

In order to migrate your current MySQL server, perform the following commands from your current server:

### Remote MySQL server

```sh
$ azk shell mysql

# Dump:

## databases structure:
$ mysqldump --host <host> --port <port> --user <user> --password -B <database name(s)> --opt -d > dbserver_schema.sql
## database data:
$ mysqldump --host <host> --port <port> --user <user> --password -B <database name(s)> --quick --single-transaction -t -n > dbserver_data.sql

# Import:
## databases structure:
$ mysql --host <host> --port <port> --user <user> --password < dbserver_schema.sql
## databases data:
$ mysql --host <host> --port <port> --user <user> --password < dbserver_data.sql
```

### Local MySQL system

```sh
$ azk shell mysql_old

# Dump:

## databases structure:
$ mysqldump -uroot -p"${MYSQL_ROOT_PASSWORD}" -B ${MYSQL_DATABASE} --opt -d > dbserver_schema.sql
## databases data:
$ mysqldump -uroot -p"${MYSQL_ROOT_PASSWORD}" -B ${MYSQL_DATABASE} --quick --single-transaction -t -n > dbserver_data.sql

# Import:
$ azk shell mysql_new
## start mysql service
$ mysqld_safe &
## databases structure:
$ mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" < dbserver_schema.sql
## databases data:
$ mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" < dbserver_data.sql
```

## License

Azuki Dockerfiles distributed under the [Apache License][license].

[license]: ./LICENSE
