# Terraform 
 - `wombat.tf` is a Terraform configuration for the wombat


## Using Terraform
1. Install Terraform https://www.terraform.io/downloads.html
2. configure AWS keys for Terraform
  - either with env vars `TF_VAR_access_key TF_VAR_secret_key` or a terraform.tfvars file
  - https://gist.github.com/scarolan/60ae8a2d5f2a8fdb5c55
3. `terraform plan` to see what resources would be built
4. `terraform apply` to build (or update) resources
5. `terraform output` to display outputs (in our case public IPs)
6. `terraform destroy` to destroy resources
