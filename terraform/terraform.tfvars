# We have to define these, but we leave them blank so that Terraform
# knows to read them from environment vars or ~/.aws/credentials
access_key = ""
secret_key = ""
key_name = ""
customer = "automate-eval"

# Type of demo you want to run. Valid options are 'linux' (default),
# 'windows', or 'all'.  The Linux demo will not spin up Windows 
# build nodes, and vice versa.

# Default AMIs for building the demo
ami-chef-server = "ami-4e748a2e"
ami-delivery-server = "ami-00e31d60"
ami-delivery-builder-1 = "ami-8c4cb0ec"
ami-workstation = ""
