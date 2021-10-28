
A1=$(vault read -format=json  vaultron_database/creds/TWGDDBMGDB03_chat_service_db_owner | jq -r '.lease_id')
A2=$(vault read -format=json  vaultron_database/creds/TWGDDBMGDB03_chat_service_db_owner | jq -r '.lease_id')
A3=$(vault read -format=json  vaultron_database/creds/TWGDDBMGDB03_chat_service_db_owner | jq -r '.lease_id')
A4=$(vault read -format=json  vaultron_database/creds/TWGDDBMGDB03_chat_service_db_owner | jq -r '.lease_id')


mssql-cli -S localhost -d chat_service  -U sa  -P Vault123 -Q "SELECT * FROM sys.database_principals";


vault lease revoke $A1
vault lease revoke $A2
vault lease revoke $A3
vault lease revoke $A4

mssql-cli -S localhost -d chat_service  -U sa  -P Vault123 -Q "SELECT * FROM sys.database_principals";
