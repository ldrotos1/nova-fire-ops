#!/bin/bash
echo "|-----------------------------------------------------------------|"
echo "| This script will create a connection property file and a pgpass |" 
echo "| file that other DB scripts will use to connect to the database. |"
echo "|-----------------------------------------------------------------|"

printf "\nEnter database host\n"
read -r host

printf "\nEnter database port\n"
read -r port

printf "\nEnter database username\n"
read -r user

printf "\nEnter database user password\n"
read -r password

mkdir -p ~/ffx-fire-ops

if [ -f ~/ffx-fire-ops/.dbconnprops ]; then
  rm ~/ffx-fire-ops/.dbconnprops
fi

if [ -f ~/ffx-fire-ops/.pgpass ]; then
  rm ~/ffx-fire-ops/.pgpass
fi

conn_props="${host}:${port}:${user}"
echo "$conn_props" > ~/ffx-fire-ops/.dbconnprops

psql_password="${host}:${port}:*:${user}:${password}"
echo "$psql_password" > ~/ffx-fire-ops/.pgpass

printf "\nDB Connection file created >> ~/ffx-fire-ops/.dbconnprops"
printf "\npgpass file created >> ~/ffx-fire-ops/.pgpass"