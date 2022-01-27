Remove-Item -LiteralPath ".terraform" -Force -Recurse

rm .terraform.lock.hcl

rm iac-bootstrap.tfplan

$RESOURCE_GROUP_NAME = "rg-base-tf-state-eastus2"
$STORAGE_ACCOUNT_NAME = "sabasetfstateastus2"

$ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY
$env:TF_CLI_ARGS_init="-backend-config='resource_group_name=rg-base-tf-state-eastus2' -backend-config='storage_account_name=sabasetfstateastus2' -backend-config='container_name=azure-landing-zone-iac-bootstrap' -backend-config='key=iac-bootstrap.terraform.tfstate'"

terraform init

terraform validate

terraform fmt

terraform plan -out="./iac-bootstrap.tfplan"