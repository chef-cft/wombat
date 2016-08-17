[![Stories in Ready](https://badge.waffle.io/chef-cft/wombat.png?label=ready&title=Ready)](https://waffle.io/chef-cft/wombat)
# `Project Wombat`
A combination of packer templates and terraform plan to configure a demo environment which includes:

* Chef Server
* Chef Automate
* Chef Compliance
* _N_ Automate Build Node(s)
* _N_ Infrastructure Nodes
* Windows Workstation


Usage
------------

##### Download your Automate license key
Automate requires a valid license to activate successfully. **If you do
not have a license key, you can request one from your CHEF account
representative.**

You will need to have the `delivery.license` file present inside `packer/files/`
directory.

##### Install and Configure ChefDK

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure chefdk as your default version of ruby.

##### Install Packer

Downloads are here: https://www.packer.io/downloads.html . Place in your path for direct execution.

##### Create a wombat.yml

Create a wombat.yml - there is an example `wombat.example.yml` for reference and easy copying
```
---
name: wombat
# Uncomment domain_prefix if you wish to prepend your generated domain.
# Ex: The below example would create foo-chef.animals.biz.
# domain_prefix: foo-
domain: animals.biz
enterprise: mammals
org: marsupials
build-nodes: '1'
workstations: '1'
workstation-passwd: 'RL9@T40BTmXh'
version: 0.2.0
products:
  chef: stable-12.13.37
  chef-server: stable-12.8.0
  chefdk: stable-0.16.28
  compliance: stable-1.3.1
  automate: stable-0.5.1
aws:
  region: ap-southeast-2
  az: ap-southeast-2c
  keypair: keypair-ap-southeast-2
  source_ami:
    ubuntu: ami-8c4cb0ec
    windows: ami-87c037e7
```

*NOTE:* workstation-passwd must meet the minimum Microsoft [Complexity Requirements](https://technet.microsoft.com/en-us/library/hh994562(v=ws.11).aspx)

##### Generate certificates and SSH Keypair

```
# generate keys
$ rake keys:create

```

##### Build AMIs with Packer

```
# build all AMIs (sequentially)
$ rake packer:build_amis

# build all AMIS (parallel)
$ rake packer:build_amis_parallel

# build just the chef-server
$ rake packer:build_ami[chef-server]

```

##### Create/update wombat.lock

```
# Update wombat.lock with latest AMIs from packer logs
$ rake update_lock
Updating lockfile based on most recent packer logs
```

##### Create CloudFormation template

```
# Create CloudFormation template from wombat.json
$ rake cfn:create_template
Generating CloudFormation template from lockfile
Generated cloudformation/wombat.json
```

##### Deploy CloudFormation template

###### via AWS CloudFormation Web UI

Upload the created template from the `cloudformation` directory.

###### via CLI

*Requires:* aws-cli and configured ~/.aws/credentials

```
# Deploy CloudFormation template
$ rake cfn:create_stack
Creating CFN stack: wombat-TIMESTAMP
```

##### 8) Login to Windows Workstation

```
# Get Windows Workstation(s) IP(s)
$ rake cfn:list_ips[wombat-TIMESTAMP]
WindowsWorkstation (i-xxxxxxxx) => XX.XXX.XX.XXX
```

From the AWS CloudFormation UI, select the Outputs tab for the desired stack.
Use an RDP compatible client to login to the workstation with the embedded credentials.

#### Terraform

Terraform is intended for use as an intermediate format for the purposes of
testing as part of a pipeline.

Downloads are here: https://www.terraform.io/downloads.html . Place in your path for direct execution.

*Note:* `access_key` and `secret_key` need to be defined so Terraform knows to read them  
from environment vars or ~/.aws/credentials

Create and populate `terraform.tfvars` in the `terraform` directory

```
access_key = ""
secret_key = ""
key_file = ""
key_name = ""
customer = "wombat"

# Customize AMIs for building the demo
ami-chef-server = ""
ami-automate = ""
ami-build-node = ""
ami-workstation = ""

```

##### Deploy images with Terraform

```
# Check the plan
$ rake tf:plan

# Apply the plan
$ rake tf:apply

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
