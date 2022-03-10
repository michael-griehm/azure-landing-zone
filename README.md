# azure-landing-zone

A repo contianing the Terraform and GitHub files needed to deploy an adequate development team landing zone within Azure.

## retrieve microsoft graph permission ids

  $> az ad sp show --id 00000003-0000-0000-c000-000000000000 >microsoft_graph_permission_list.json
