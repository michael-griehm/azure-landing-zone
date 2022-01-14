$RESOURCE_GROUP_NAME = "rg-opentfstate-eastus2"
$STORAGE_ACCOUNT_NAME = "saopentfstateastus2"

$ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY

terraform init

terraform validate

terraform fmt

terraform plan -out="./iam.tfplan"