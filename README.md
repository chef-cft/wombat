# `Project Wombat`
A combination of packer templates and terraform plan to configure a demo environment which includes:

* Chef Server 12
* Chef Delivery
* Chef Build Node for Delivery
* Windows Workstation


Usage
------------

##### 1) Download your Delivery license key
Delivery requires a valid license to activate successfully. **If you do
not have a license key, you can request one from your CHEF account
representative.**

You will need to have the `delivery.license` file present inside `packer/files/`
directory.

##### 2) Install and Configure ChefDK

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure chefdk as your default version of ruby.

##### 3) Install Packer

Downloads are here: https://www.packer.io/downloads.html . Place in your path for direct execution.

##### 4) Install Terraform

Downloads are here: https://www.terraform.io/downloads.html . Place in your path for direct execution.

##### 5) Create and populate `terraform.tfvars` in the `terraform` directory

```
access_key = ""
secret_key = ""
key_file = ""
key_name = ""
customer = "automate-eval"

# Customize AMIs for building the demo
ami-chef-server = ""
ami-delivery-server = ""
ami-delivery-builder = ""
ami-workstation = ""

```

* `access_key` and `secret_key` need to be defined so Terraform knows to read them  
from environment vars or ~/.aws/credentials

##### 6) Build Images with Packer

```
# build all images
$ rake packerize

# build one image
$ rake packerize:chef_server

# build one image directly for AWS
$ cd packer
$ packer build --only amazon-ebs chef-server.json

```

##### 7) Deploy images with Terraform

```
# Check the plan
$ rake terraform:plan

# Apply the plan
$ rake terraform:apply

# alternatively
$ cd terraform
$ terraform plan
$ terraform apply
```

#### Access to Resources

Terraform will output the list of Public IPs for each server after an apply. Access to Linux resources
via SSH can be had using the embedded key or by the key_pair used to create the resources in AWS. To
access the Windows workstation use the credentials from the Packer template/bootstrap.txt with the
Microsoft Remote Desktop Client.

To list the IPs of a running stack
```
$ cd terraform
$ terraform output
```

#### TODO

* Document Azure build process / Abstract existing AWS build process
*

LICENSE AND AUTHORS
===================
* [Andre Elizondo](https://github.com/andrewelizondo)
* [Seth Thomas](https://github.com/cheeseplus)

```text
Copyright:: 2015 Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
