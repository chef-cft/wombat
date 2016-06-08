# `Project Wombat`
A combination of packer templates and terraform plan to configure a demo environment which includes:

* Chef Server 12
* Chef Delivery
* Chef Build Node for Delivery
* Windows Workstation


Usage
------------

##### Download your Delivery license key
Delivery requires a valid license to activate successfully. **If you do
not have a license key, you can request one from your CHEF account
representative.**

You will need to have the `delivery.license` file present inside `packer/files/`
directory.

##### Install and Configure ChefDK

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure chefdk as your default version of ruby.

##### Install Packer

Downloads are here: https://www.packer.io/downloads.html . Place in your path for direct execution.

##### Create a wombat.json

Create a wombat.json - there is an example `wombat.example.json` for reference and easy copying
```
{
  "aws": {
    "availability_zone": "ap-southeast-2c",
    "keypair": "keypair-ap-southeast-2",
    "region": "ap-southeast-2",
    "amis": {
      "us-west-1": {
        "chef-server": "ami-83d129e3",
        "delivery": "ami-29d42c49",
        "build-node": {
            "1": "ami-27d12947"
        },
        "workstation": "ami-f7d32b97"
      }
    }
  },
  "demo": "wombat",
  "domain": "chordata.biz",
  "enterprise": "mammalia",
  "org": "diprotodontia",
  "version": "0.0.12",
  "build-nodes": "1",
  "pkg-versions": {
    "chef-server": "12.6.0",
    "chefdk": "0.14.25",
    "delivery": "0.4.317"
  },
  "last_updated": "20160605163503"
}
```
Fill in the fields as approrpriate for your infrastructure and credentials.

*Note*: The `amis` hash and the `last_updated` keys are updated by the rake tasks and do not need to be populated.

##### Generate certificates and SSH Keypair

```
# generate keys
$ rake keys:create

```

##### Build AMIs with Packer

```
# build all AMIs
$ rake aws:pack_amis

# build one image
$ rake aws:pack_ami[chef-server]

```

##### Update wombat.json

```
# Update wombat.json with latest AMIs from packer logs
$ rake aws:update_amis

```

##### Create CloudFormation template

```
# Create CloudFormation template from wombat.json
$ rake aws:create_cfn_template
```

##### Deploy CloudFormation template

###### via AWS CloudFormation Web UI

Upload the created template from the `cloudformation` directory.

###### via CLI

*Requires:* aws-cli and configured ~/.aws/credentials

```
# Deploy CloudFormation template
$ rake aws:create_cfn_stack
```

##### 8) Login to Windows Workstation

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
customer = "automate-eval"

# Customize AMIs for building the demo
ami-chef-server = ""
ami-delivery = ""
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
