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

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure ChefDK as your default version of ruby.

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
    windows: ami-1712d877
```

*NOTE:* workstation-passwd must meet the minimum Microsoft [Complexity Requirements](https://technet.microsoft.com/en-us/library/hh994562(v=ws.11).aspx)

##### Build images with Packer

```
# build one template
$ rake build:image[chef-server,aws]

# build all templates (sequentially)
$ rake build:images[aws]

# build all images (parallel)
$ rake build:images_parallel[aws]
```

*NOTE:* If the builder (aws, gce, ...) is not provided or is any value beside 'gce', it defaults to 'aws'.
There is currently GCE support but image building but not deployment.

##### Deploy CloudFormation template

###### via AWS CloudFormation Web UI

Upload the created template from the `cloudformation` directory.

###### via CLI

```
# Deploy CloudFormation template
$ rake cfn:create_stack
Creating CFN stack: wombat-TIMESTAMP
```

##### Login to Windows Workstation

```
# Get Windows Workstation(s) IP(s)
$ rake cfn:list_ips[wombat-TIMESTAMP]
WindowsWorkstation (i-xxxxxxxx) => XX.XXX.XX.XXX
```

From the AWS CloudFormation UI, select the Outputs tab for the desired stack.
Use an RDP compatible client to login to the workstation with the embedded credentials.

LICENSE AND AUTHORS
===================
* [Andre Elizondo](https://github.com/andrewelizondo)
* [Seth Thomas](https://github.com/cheeseplus)

```text
Copyright:: 2016 Chef Software, Inc

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
