az group create --location japaneast --resource-group CloudeApp 
#rồi tạo secret cho github repo AZURE_CREDENTIALS
export AZURE_SUBSCRIPTION_ID=$(az account show --output tsv --query id)
az ad sp create-for-rbac --name "ctb" --role contributor --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/CloudeApp --json-auth --skip-assignment

export ACRP_USERNAME=regfruit
export ACRP_SERVER="$ACRP_USERNAME.azurecr.io"
az acr create --resource-group CloudeApp --name $ACRP_USERNAME --sku Basic --admin-enabled true

export ACRP_PASSWORD=$(az acr credential show --name $ACRP_USERNAME --query "passwords[0].value" --output tsv)
export DOCKER_EMAIL="20521414@ms.edu.uit.vn"

rm -rvf kuber-app-yaml
git clone https://github.com/JakiroDust/kuber-app-yaml


az deployment group create \
  --resource-group CloudeApp \
  --template-file kuber-app-yaml/kuber-dev/template.json \
  --parameters kuber-app-yaml/kuber-dev/parameters.json
kubectl config use-context devkuber

az account set --subscription $AZURE_SUBSCRIPTION_ID
az aks get-credentials --resource-group CloudeApp --name devkuber

kubectl create secret docker-registry reg_sec \
  --docker-server=$ACRP_SERVER \
  --docker-username=$ACRP_USERNAME \
  --docker-password=$ACRP_PASSWORD \
  --docker-email=$DOCKER_EMAIL \
  --namespace="default"
