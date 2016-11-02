## Anatomy of a Wombat

### tl;dr

Wombat is a collection of code that builds Chef configured golden
images from packer templates that are then re-consumed by a Cloud service template such
as CloudFormation or Google Deployment Manager.

### Design Goals

* coordination without coordination
* principle of least surprise
* dynamic templates over static files
* long build times, short deploy times

### A Stroll Down Architecture Lane

The core of wombat is the binary `bin/wombat`.


`wombat build -o BUILDER TEMPLATE`

1. Generate x509 certificates for the domain and ssh keys if there are none
2. Vendor cookbooks for template
3. Build Packer images for -o BUILDER (amazon-ebs|googlecompute) with included cookbooks

* If the TEMPLATE argument is not provided it will execute against all templates in `./packer/`

`wombat update lock`

1. Create/update wombat.lock based on most recent Packer logs

`wombat update template`

1. Create cfn/gdm configuration from lock

* If no argument is  provided it will update _both_ lock and template

`wombat deploy STACK`

1. Deploy cfn/gdm stack

`wombat outputs STACK`

1. List outputs, specifically Workstation IPs

`wombat delete STACK`

1. Delete stack
