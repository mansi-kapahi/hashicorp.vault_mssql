#!/bin/bash
export VAULT_TOKEN=$(grep 'VAULT_TOKEN' /home/vagrant/.bashrc | cut -d '=' -f 2)
export VAULT_ADDR=$(grep 'VAULT_ADDR' /home/vagrant/.bashrc | cut -d '=' -f 2)

# // logger
function pOUT() { printf "$1\n" ; } ;

# // Colourised logger for errors (red)
function pERR()
{
	# sMSG=${1/@('ERROR:')/"\e[31mERROR:\e[0m"} ; sMSG=${1/('ERROR:')/"\e[31mERROR:\e[0m"}
	if [[ $1 == "--"* ]] ; then pOUT "\e[31m$1\n\e[0m\n" ;
	else pOUT "\n\e[31m$1\n\e[0m\n" ; fi ;
}


VVERSION=$(vault --version) ;
if ! [[ ${VVERSION} == *"ent"* ]] ; then
	pERR "VAULT ENTERPRISE REQUIRED! - but found: ${VVERSION}\n" ; exit 1 ;
fi ;

if [[ ${VAULT_TOKEN} == "" ]] ; then
	# // VAULT_TOKEN ought to exist by now from either init or copy from vault1:
	VAULT_TOKEN=$(grep -F VAULT_TOKEN ${HOME_PATH}/.bashrc | cut -d'=' -f2) ;
fi ;

if [[ ${VAULT_TOKEN} == "" ]] ; then pERR 'VAULT ERROR: No Token Found.\n' ; exit 1 ; fi ;

# // enable Vault Audits.
VAULT_AUDIT_PATH='vaudit.log' ;
vault audit enable file file_path=${VAULT_AUDIT_PATH} > /dev/null ;
if (($? == 0)) ; then pOUT "VAULT: Audit logs enabled at: ${VAULT_AUDIT_PATH}\n" ;
else pERR 'VAULT ERROR: NOT ABLE TO ENABLE AUDITS.\n' ; fi ;

vault secrets enable -path=vaultron_database database
if (($? == 0)) ; then pOUT 'VAULT: vault databse engine enabled  "vaultron_database"\n' ;
else pERR 'VAULT ERROR: NOT ABLE TO ENABLE database.\n' ; fi ; 

vault write vaultron_database/config/TWGDDBMGDB03 plugin_name=mssql-database-plugin connection_url='sqlserver://sa:Vault123@127.0.0.1:1433'\
 allowed_roles="TWGDDBMGDB03_application_properties_db_datareader_datawriter","TWGDDBMGDB03_chat_service_db_owner","TWGDDBMGDB03_niku_db_datareader"


vault write vaultron_database/roles/TWGDDBMGDB03_chat_service_db_owner db_name=TWGDDBMGDB03 \
 creation_statements="USE [master]; CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}'; USE [chat_service]; CREATE USER [{{name}}] FOR LOGIN [{{name}}]; USE [chat_service]; ALTER ROLE [db_owner] ADD MEMBER [{{name}}]; USE [chat_service];"\
  default_ttl="1h"  max_ttl="24h"
