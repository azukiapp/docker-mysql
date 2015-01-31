#!/bin/bash

VOLUME_HOME="/var/lib/mysql"
CONF_FILE="/etc/mysql/conf.d/my.cnf"
LOG="/var/log/mysql/error.log"

# Set permission of config file
chmod 644 ${CONF_FILE}
chmod 644 /etc/mysql/conf.d/mysqld_charset.cnf

StartMySQL () {
  /usr/bin/mysqld_safe > /dev/null 2>&1 &

  # Time out in 1 minute
  LOOP_LIMIT=13
  for (( i=0 ; ; i++ )); do
    if [ ${i} -eq ${LOOP_LIMIT} ]; then
      echo "Time out. Error log is shown as below:"
      tail -n 100 ${LOG}
      exit 1
    fi
    echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1 && break
  done
}

CreateMySQLUser() {
  StartMySQL
  if [ "$MYSQL_PASS" = "**Random**" ]; then
      unset MYSQL_PASS
  fi

  PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
  _word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
  echo "=> Creating MySQL user ${MYSQL_USER} with ${_word} password"

  mysql -uroot -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '$PASS'"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION"

  echo "=> Done!"

  echo "========================================================================"
  echo "You can now connect to this MySQL Server using:"
  echo ""
  echo "    mysql --user $MYSQL_USER --password $PASS --host <host> --port <port>"
  echo ""
  echo "Please remember to change the above password as soon as possible!"
  echo "MySQL user 'root' has no password but only allows local connections"
  echo "========================================================================"

  mysqladmin -uroot shutdown
}

ImportSql() {
  StartMySQL

  for FILE in ${STARTUP_SQL}; do
   echo "=> Importing SQL file ${FILE}"
   mysql -uroot < "${FILE}"
  done

  mysqladmin -uroot shutdown
}

# Initialize empty data volume and create MySQL user
if [[ ! -d $VOLUME_HOME/mysql ]]; then
  echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
  echo "=> Installing MySQL ..."
  if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
      cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
  fi
  mysql_install_db > /dev/null 2>&1
  echo "=> Done!"
  echo "=> Creating admin user ..."
  CreateMySQLUser
else
  echo "=> Using an existing volume of MySQL"
fi

# Import Startup SQL
if [ -n "${STARTUP_SQL}" ]; then
  if [ ! -f /sql_imported ]; then
    echo "=> Initializing DB with ${STARTUP_SQL}"
    ImportSql
    touch /sql_imported
  fi
fi

tail -F $LOG &
exec mysqld_safe
