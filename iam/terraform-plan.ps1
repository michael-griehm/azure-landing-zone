$RESOURCE_GROUP_NAME = "rg-opentfstate-eastus2"
$STORAGE_ACCOUNT_NAME = "saopentfstateastus2"

$ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY
$env:TF_CLI_ARGS_init="-backend-config='resource_group_name=rg-opentfstate-eastus2' -backend-config='storage_account_name=saopentfstateastus2' -backend-config='container_name=rg-bootstrapper-iam-state' -backend-config='key=iam.terraform.tfstate'"

terraform init -input=false -upgrade

terraform validate

terraform fmt

terraform plan -out="./iam.tfplan"