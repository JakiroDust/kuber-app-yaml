export AZURE_SUBSCRIPTION_ID=$(az account show --output tsv --query id)
az ad sp create-for-rbac --name "ctb" --role contributor --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/CloudeApp --json-auth --skip-assignment
#go to github secret action 