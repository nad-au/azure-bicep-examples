# azure-bicep-examples
Infrastructure as code using Azure Bicep and GitHub Actions

# Local Testing

```bash
az login
```

Set subscription

```bash
az account list --output table

az account set --subscription <Subscription Id>
```

Create resources

```bash
az group create --name rg-bicep-examples-plat --location eastus
az deployment group create --name platform-us --resource-group rg-bicep-examples-plat --template-file .bicep/platform-infra.bicep --parameters postgresPassword=bicep.examples@2022$

az group create --name rg-bicep-examples-dmn --location eastus
az deployment sub create --name domain-us --template-file .bicep/domain-infra.bicep --location eastus --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn

az deployment sub create --name app1-us --template-file .bicep/app1-infra.bicep --location eastus --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn dockerImage=mcr.microsoft.com/azuredocs/containerapps-helloworld:latest
az deployment sub create --name app2-us --template-file .bicep/app2-infra.bicep --location eastus --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn dockerImage=mcr.microsoft.com/azuredocs/containerapps-helloworld:latest
az deployment sub create --name app3-us --template-file .bicep/app3-infra.bicep --location eastus --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn
az deployment sub create --name app4-us --template-file .bicep/app4-infra.bicep --location eastus --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn
```

Delete resources

```bash
az group delete --name rg-bicep-examples-dmn
az group delete --name rg-bicep-examples-plat
```
