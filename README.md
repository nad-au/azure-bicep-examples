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
az group create --name rg-bicep-examples-plat --location australiaeast
az deployment group create --name dp-platform-infra-au --resource-group rg-bicep-examples-plat --template-file .bicep/platform-infra.bicep --parameters postgresPassword=bicep.examples@2022$

az group create --name rg-bicep-examples-dmn --location australiaeast
az deployment sub create --name dp-domain-infra-au --template-file .bicep/domain-infra.bicep --location australiaeast --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn

az deployment sub create --name dp-app1-infra-au --template-file .bicep/app1-infra.bicep --location australiaeast --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn dockerImage=mcr.microsoft.com/azuredocs/containerapps-helloworld:latest
az deployment sub create --name dp-app2-infra-au --template-file .bicep/app2-infra.bicep --location australiaeast --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn dockerImage=mcr.microsoft.com/azuredocs/containerapps-helloworld:latest
az deployment sub create --name dp-app3-infra-au --template-file .bicep/app3-infra.bicep --location australiaeast --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn
az deployment sub create --name dp-app4-infra-au --template-file .bicep/app4-infra.bicep --location australiaeast --parameters platformResourceGroup=rg-bicep-examples-plat domainResourceGroup=rg-bicep-examples-dmn
```

Delete resources

```bash
az group delete --name rg-bicep-examples-dmn
az group delete --name rg-bicep-examples-plat
```
