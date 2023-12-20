
az login

#clone deploy yaml
git clone https://github.com/JakiroDust/kuber-app-yaml

#create resource group 
az group create --location japaneast --resource-group CloudeApp 

#get access Token for 
export regdev_accessToken=$(az acr login -n reghuydev --expose-token --output tsv --query accessToken)
export AZURE_SUBSCRIPTION_ID=$(az account show --output tsv --query id)
export AZURE_CREDENTIALS=$(az ad sp create-for-rbac --name "ctb" --role contributor --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/CloudeApp --json-auth --skip-assignment)




echo $AZURE_CREDENTIALS > azure-credentials.json

kubectl create secret docker-registry accs \
    --namespace default \
    --docker-server=reghuydev.azurecr.io \
    --docker-username=<service-principal-ID> \
    --docker-password=<service-principal-password>


docker login reghuydev.azurecr.io -u 00000000-0000-0000-0000-000000000000 --password-stdin <<< $regdev_accessToken

az acr update -n reghuydev --admin-enabled true

git clone https://github.com/JakiroDust/Web_FruitShop

#build and push image to registry
az acr build --registry reghuydev --file ./df-php . --image webimage:latest
##az acr build --registry reghuydev --file ./df-sql . --image df-sql:latest


#clone github for deploy kubernetes
git clone https://github.com/JakiroDust/kuber-app-yaml
cd kuber-app-yaml

az deployment group create \
  --resource-group CloudeApp \
  --template-file template.json \
  --parameters parameters.json


az aks get-credentials --resource-group CloudeApp --name devkuber

cd ../../
kubectl apply -f ./mani/mani-dev.yaml