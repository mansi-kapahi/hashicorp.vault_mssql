#!/bin/bash
export DEBIAN_FRONTEND=noninteractive ;
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

wget -q  https://packages.microsoft.com/ubuntu/16.04/prod/pool/main/m/mssql-cli/mssql-cli_1.0.0-1_all.deb

sudo dpkg -f  mssql-cli_1.0.0-1_all.deb
set +eu ; # abort this script when a command fails or an unset variable is used.

sudo dpkg -i  mssql-cli_1.0.0-1_all.deb
set -eu ; # abort this script when a command fails or an unset variable is used.



if docker run \
    -e 'ACCEPT_EULA=Y' \
    -e 'MSSQL_SA_PASSWORD=v4u1tr0n_in_the_h@use' \
    -e 'MSSQL_PID=Developer' \
    -p 1433:1433 \
    --name vaultron_mssql \
    -d mcr.microsoft.com/mssql/server:2019-latest 2>&1 > /dev/null ; then  
	echo "DOCKER HAS RUN" 
else	
	echo "ISSUE IN DOCKER RUN"
fi 
#Change the password 

sleep 10
if docker exec \
    -i vaultron_mssql /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U SA -P 'v4u1tr0n_in_the_h@use' \
    -Q 'ALTER LOGIN SA WITH PASSWORD="Vault123"' 2>&1 > /dev/null  ; then 
	echo "MSSQL PASSWORD CHANGED" 
else 
	echo "MSSQL CHANGING PASSWORD ISSUE"
fi

/usr/bin/mssql-cli -S localhost  -U sa  -P Vault123 -Q "CREATE DATABASE chat_service" ;

