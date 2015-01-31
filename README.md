[azukiapp/mysql](http://images.azk.io/#/mysql)
==================

Base docker image to run a MySQL database server in [`azk`](http://azk.io)

MySQL versions (tags)
---

- [`5,6`, `5`, `latest`](https://github.com/azukiapp/docker-mysql/blob/master/5.6/Dockerfile)
- [`5,5`](https://github.com/azukiapp/docker-mysql/blob/master/5.5/Dockerfile)

Image content:

- Ubuntu 14.04
- Git
- VIM
- MySQL

Usage
-----

### with `azk`
Example of using that image with the [azk](http://azk.io):

```js
/**
 * Documentation: http://docs.azk.io/Azkfile.js
 */

// Adds the systems that shape your system
systems({
  mysql: {
    // Dependent systems
    depends: [],
    // More images:  http://images.azk.io
    image: {"docker": "azukiapp/mysql"},
    shell: "/bin/bash",
    wait: {"retry": 25, "timeout": 1000},
    mounts: {
      '/var/lib/mysql': persistent("mysql_lib#{system.name}"),
    },
    ports: {
      // exports global variables
      data: "3306/tcp",
    },
    envs: {
      // set instances variables
      MYSQL_USER         : "azk",
      MYSQL_PASS         : "azk",
      MYSQL_DATABASE     : "#{system.name}_development",
    },
    export_envs: {
      // check this gist to configure your database
      // https://gist.github.com/gullitmiranda/62082f2e47c364ef9617
      DATABASE_URL: "mysql2://#{envs.MYSQL_USER}:#{envs.MYSQL_PASS}@#{net.host}:#{net.port.data}/${envs.MYSQL_DATABASE}",
    },
  },
});
```


### with `docker`
To create the image `azukiapp/mysql`, execute the following command on the docker-mysql folder:

```sh
$ docker build -t azukiapp/mysql 5.6/
```

To run the image and bind to port 3306:

```sh
$ docker run -d -p 3306:3306 azukiapp/mysql
```

The first time that you run your container, a new user `admin` with all privileges 
will be created in MySQL with a random password. To get the password, check the logs
of the container by running:


```sh
# with azk
$ azk logs mysql

# with docker
$ docker logs <CONTAINER_ID>
```

You will see an output like the following:

        ========================================================================
        You can now connect to this MySQL Server using:

            mysql -u azk -p azk -h <host> -P <port>

        Please remember to change the above password as soon as possible!
        MySQL user 'root' has no password but only allows local connections
        ========================================================================

In this case, `azk` is the password allocated to the `azk` user.

Remember that the `root` user has no password but it's only accessible from within the container.

Environment variables
---------------------

`MYSQL_USER`: Set a specific username for the admin account. (default 'azk')

`MYSQL_PASS`: Set a specific password for the admin account. (default 'azk')

`STARTUP_SQL`: Defines one or more sql scripts separated by spaces to initialize the database. Note that the scripts must be inside the conainer so you may need to mount them


Migrating an existing MySQL Server
----------------------------------

In order to migrate your current MySQL server, perform the following commands from your current server:

```sh
$ azk shell mysql

### Dump databases structure:
$ mysqldump --host <host> --port <port> --user <user> --password --opt -d -B <database name(s)> > dbserver_schema.sql

### Dump database data:
$ mysqldump --host <host> --port <port> --user <user> --password --quick --single-transaction -t -n -B <database name(s)> > dbserver_data.sql
```

To import a SQL backup which is stored for example in the project root, run the following:

```
$ azk shell mysql
$ /import_sql.sh <user> <pass> <dump.sql>
```

## License

Azuki Dockerfiles distributed under the [Apache License](https://github.com/azukiapp/dockerfiles/blob/master/LICENSE).
