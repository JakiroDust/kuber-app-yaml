az group create --location japaneast --resource-group CloudeApp 
#rồi tạo secret cho github repo AZURE_CREDENTIALS
export AZURE_SUBSCRIPTION_ID=$(az account show --output tsv --query id) 
export ACRP_USERNAME=regfruit
export ACRP_SERVER="$ACRP_USERNAME.azurecr.io"

az acr create --resource-group CloudeApp --name $ACRP_USERNAME --sku Basic --admin-enabled true
az acr update -n regfruit --admin-enabled true

export regdev_accessToken=$(az acr login -n regfruit --expose-token --output tsv --query accessToken)
docker login regfruit.azurecr.io -u 00000000-0000-0000-0000-000000000000 --password-stdin <<< $regdev_accessToken



export ACRP_PASSWORD=$(az acr credential show --name $ACRP_USERNAME --query "passwords[0].value" --output tsv)
export DOCKER_EMAIL="20521414@ms.edu.uit.vn"

rm -rvf kuber-app-yaml
git clone https://github.com/JakiroDust/kuber-app-yaml
rm -rvf Web_FruitShop
git clone https://github.com/JakiroDust/Web_FruitShop

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


cd ./Web_FruitShop/
az acr build --registry regfruit --file ./Web_FruitShop/df-php . --image webimage:latest



#export for database
export PGHOST=dbcloudeapp.postgres.database.azure.com
export PGUSER=citus
export PGPORT=5432
export PGDATABASE=postgres
export PGPASSWORD=21072002HUYhuy!