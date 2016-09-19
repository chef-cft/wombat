[![Stories in Ready](https://badge.waffle.io/chef-cft/wombat.png?label=ready&title=Ready)](https://waffle.io/chef-cft/wombat)
# `Project Wombat`
`wombat` is a gem that builds and creates demo environments using cloud-specific deployment
tools like CloudFormation. The demo environments are comprised of instances built
from the included packer templates:

* Chef Server
* Chef Automate
* Chef Compliance
* _N_ Automate Build Node(s)
* _N_ Infrastructure Nodes
* _N_ Windows Workstation

Usage
------------

##### Download your Automate license key
Automate requires a valid license to activate successfully. **If you do
not have a license key, you can request one from your CHEF account
representative.**

You will need to have the `delivery.license` file present inside `packer/files/`
directory.

##### Install and Configure ChefDK

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure ChefDK as your default version of Ruby.

##### Install Packer

Downloads are here: https://www.packer.io/downloads.html . Place in your path for direct execution.

##### Create a wombat.yml

Create a wombat.yml - there is an example `wombat.example.yml` for reference and easy copying

*NOTE:* workstation-passwd must meet the minimum Microsoft [Complexity Requirements](https://technet.microsoft.com/en-us/library/hh994562(v=ws.11).aspx)

*NOTE:* The `googlecompute` and `azure` builders exist but not all images will build nor is there deployment support for either at this time.

##### Build images with Packer

```
# build one or more templates
$ bin/wombat build [-o BUILDER] TEMPLATE [TEMPLATE2]

# build all templates (sequentially)
$ bin/wombat build [-o BUILDER]

# build all images (parallel)
$ bin/wombat build [-o BUILDER] --parallel
```

*NOTE:* If the builder is not provided it defaults to `amazon-ebs`

##### Deploy CloudFormation template

###### via AWS CloudFormation Web UI

Upload the created template from the `cloudformation` directory.

###### via CLI

```
# Deploy CloudFormation template
$ bin/wombat deploy --cloud aws STACK
==> Updating wombat.lock
==> Generate CloudFormation JSON: STACK.json
==> Creating CloudFormation stack
Created: arn:aws:cloudformation:us-east-1:862552916454:stack/STACK/2160c580-713e-11e6-b392-50a686e4bb82
```

*NOTE:* If the cloud is not provided it defaults to `aws`

##### Login to Windows Workstation

```
# Get Windows Workstation(s) IP(s)
$ bin/wombat outputs STACK
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
