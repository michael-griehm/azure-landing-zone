# azure-landing-zone

This repo contians the Terraform and GitHub Workflow files needed to deploy a basic development team landing zone within Azure.

## What is a Landing Zone?

A 'landing zone' is a collection of Azure AD Groups and Resources needed for a development team to start developing their worklaod within Azure, enabling the Development Team autonomy develop and deploy at their own pace.

## What are the components of a Landing Zone?

- [Resource Group](modules/landing-zone/main.tf#L21)
  - The development area of the workload.
  - Service Principals and Users will be granted Role Basec Access to this area via Azure Active Directory Group Membership.
- [Key Vault](modules/landing-zone/key-vault.tf)
  - Key Vault to securely store the secrets, passwords, and access keys needed for depoyment using Terraform within a GitHub Workflow.
- [Storage Account](modules/landing-zone/storage-account.tf)
  - Storage Account used to securely store the Terraform Remote State file needed to manage the lifecycle of the Azure infrastrucutre that supports the workload.
- [Azure AD Service Principal for RBAC](modules/landing-zone/ad-service-principal.tf)
  - Service Principal to be used in the workload's CI-CD Pipeline.
  - Will be assigned the RBAC role of Owner on the Resource Group via Azure AD Group Membership.
- [Azure Active Directory Groups](modules/landing-zone/ad-groups.tf)
  - [Deployer Group](modules/landing-zone/ad-groups.tf#L1)
    - Assigned the Owner RBAC role on the Resource Group.
  - [Contributor Group](modules/landing-zone/ad-groups.tf#L17)
    - Assigned the Contributor RBAC role on the Resource Group.
  - [Reader Group](modules/landing-zone/ad-groups.tf#L33)
    - Assigned the Reader RBAC role on the Resource Group.
- [Workload Admin Azure AD User](modules/landing-zone/main.tf#L17)
  - Assigned Owner and other certain ACLs within the Landing Zone Azure Resources needed to help manage the development and deployment of the workload.

## Repo Folder Structure

- [modules/landing-zone](modules/landing-zone/)
  - Contains the Terraform files that represent the Landing Zone module.
- [instances/](instances/)
  - Contains subfolders for each of the Landing Zone instances managed by this repo.  Each Landing Zone subfolder contains the main.tf file that describes each implementation of the Landing Zone module.
- [.github/workflows](.github/workflows/)
  - Contains the GitHub Workflow files used to deploy and destroy each of the Landing Zone instances.  There is one deploy file and one destroy file (seperate files) for each of the Landing Zone instances.  This is done to decouple the deployment and Terraform remote state files of each Landing Zone from one another as a risk mitigation strategy as well as an agility strategy.
- [iac-bootstrap](iac-bootstrap/)
  - Solution to the chicken and the egg paradox when it comes to Terraform remote state management when using cloud provider resources to house the remote state file.  The Terraform file and PowerShell code in here are used to create the Landing Zone's own Resource Group, Terraform Remote State Storage Account, Deployer Key Vault, and Deployer Service Principal.  The PowerShell code was executed by a Subscription Owner persona locally to seed the resources needed to setup a enterprise grade deployment model.

## Microsoft Graph API Permission Ids

  $> az ad sp show --id 00000003-0000-0000-c000-000000000000 >microsoft_graph_permission_list.json
