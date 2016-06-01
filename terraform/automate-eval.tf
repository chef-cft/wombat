variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "us-west-2"
}
variable "az" {
    default = "us-west-2c"
}
variable "customer" {
    default = "venture-industries"
}
variable "key_file" {
    default = "../packer/keys/private.pem"
}
variable "key_name" {
    default = "USER_REGION"
}
variable "ttl" {
    default = 8
}
variable "num_builders" {
    default = 0
}
variable "ami-chef-server" {
  default = "ami-f3f10893"
}
variable "ami-delivery-server" {
  default = "ami-6abf460a"
}
variable "ami-delivery-builder" {
  default = "ami-8c4cb0ec"
}
variable "ami-workstation" {
  default = "ami-e8f90088"
}

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_vpc" "automate-eval" {
    cidr_block           = "172.31.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
      "Customer" = "${var.customer}"
      "TTL" = "${var.ttl}"
      "Name" = "automate-eval VPC"
    }
}

resource "aws_subnet" "delivery" {
    vpc_id                  = "${aws_vpc.automate-eval.id}"
    cidr_block              = "172.31.54.0/24"
    availability_zone       = "${var.az}"
    map_public_ip_on_launch = false

    tags {
        "Customer" = "${var.customer}"
        "TTL" = "${var.ttl}"
        "Name" = "${var.customer} automate-eval Delivery Subnet"
    }
}

resource "aws_subnet" "prod" {
    vpc_id                  = "${aws_vpc.automate-eval.id}"
    cidr_block              = "172.31.62.0/24"
    availability_zone       = "${var.az}"
    map_public_ip_on_launch = false

    tags {
      "Customer" = "${var.customer}"
      "TTL" = "${var.ttl}"
      "Name" = "automate-eval prod subnet"
    }
}

resource "aws_subnet" "workstations" {
    vpc_id                  = "${aws_vpc.automate-eval.id}"
    cidr_block              = "172.31.10.0/24"
    availability_zone       = "${var.az}"
    map_public_ip_on_launch = false

    tags {
      "Customer" = "${var.customer}"
      "TTL" = "${var.ttl}"
      "Name" = "automate-eval workstations subnet"
    }
}

resource "aws_internet_gateway" "inet-gw" {
    vpc_id = "${aws_vpc.automate-eval.id}"

    tags {
      "Customer" = "${var.customer}"
      "Name" = "automate-eval IG"
      "TTL" = "${var.ttl}"
    }
}

resource "aws_route_table" "route-table" {
    vpc_id     = "${aws_vpc.automate-eval.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.inet-gw.id}"
    }

    tags {
      "Customer" = "${var.customer}"
      "Name" = "automate-eval RouteTable"
      "TTL" = "${var.ttl}"
    }
}

resource "aws_route_table_association" "delivery-rta" {
    route_table_id = "${aws_route_table.route-table.id}"
    subnet_id = "${aws_subnet.delivery.id}"
}

resource "aws_route_table_association" "prod-rta" {
    route_table_id = "${aws_route_table.route-table.id}"
    subnet_id = "${aws_subnet.prod.id}"
}

resource "aws_route_table_association" "workstations-rta" {
    route_table_id = "${aws_route_table.route-table.id}"
    subnet_id = "${aws_subnet.workstations.id}"
}

resource "aws_network_acl" "automate-eval-network-acl" {
    vpc_id     = "${aws_vpc.automate-eval.id}"
    subnet_ids = ["${aws_subnet.delivery.id}", "${aws_subnet.prod.id}", "${aws_subnet.workstations.id}"]

    ingress {
        from_port  = 0
        to_port    = 0
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    egress {
        from_port  = 0
        to_port    = 0
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    tags {
      "Customer" = "${var.customer}"
      "TTL" = "${var.ttl}"
      "Name" = "automate-eval NetworkAcl"
    }
}

resource "aws_instance" "chef-server" {
    ami                         = "${var.ami-chef-server}"
    availability_zone           = "${var.az}"
    instance_type               = "c3.xlarge"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${aws_subnet.delivery.id}"
    vpc_security_group_ids      = ["${aws_security_group.automate-eval.id}"]
    associate_public_ip_address = true
    private_ip                  = "172.31.54.10"

    tags {
        "Customer" = "${var.customer}"
        "Name" = "automate-eval chef server"
        "TTL" = "${var.ttl}"
    }

    provisioner "remote-exec" {
      connection {
        user = "ubuntu"
        host = "${aws_instance.chef-server.public_ip}"
        timeout = "1m"
        key_file = "${var.key_file}"
      }
      inline = [
        "sudo hostnamectl set-hostname chef-server",
        "sudo chef-server-ctl reconfigure",
        "sudo chef-manage-ctl reconfigure",
        "sudo opscode-push-jobs-server-ctl reconfigure"
      ]
    }
}

resource "aws_instance" "delivery-server" {
    ami                         = "${var.ami-delivery-server}"
    availability_zone           = "${var.az}"
    instance_type               = "c3.xlarge"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${aws_subnet.delivery.id}"
    vpc_security_group_ids      = ["${aws_security_group.automate-eval.id}"]
    associate_public_ip_address = true
    private_ip                  = "172.31.54.11"

    tags {
      "Customer" = "${var.customer}"
      "Name" = "automate-eval delivery server"
      "TTL" = "${var.ttl}"
    }

    provisioner "remote-exec" {
      connection {
        user = "ubuntu"
        host = "${aws_instance.delivery-server.public_ip}"
        timeout = "1m"
        key_file = "${var.key_file}"
      }
      inline = [
        "sudo hostnamectl set-hostname delivery-server",
        "sudo delivery-ctl reconfigure"
      ]
    }
}

resource "aws_instance" "delivery-builder-1" {
    ami                         = "${var.ami-delivery-builder}"
    availability_zone           = "${var.az}"
    instance_type               = "c3.large"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${aws_subnet.delivery.id}"
    vpc_security_group_ids      = ["${aws_security_group.automate-eval.id}"]
    associate_public_ip_address = true
    private_ip                  = "172.31.54.12"

    tags {
      "Customer" = "${var.customer}"
      "Name" = "automate-eval delivery build node 1"
      "TTL" = "${var.ttl}"
    }

    provisioner "remote-exec" {
      connection {
        user = "ubuntu"
        host = "${aws_instance.delivery-server.public_ip}"
        timeout = "1m"
        key_file = "${var.key_file}"
      }
      inline = [
        "sudo hostnamectl set-hostname delivery-builder-1"
      ]
    }
}

resource "aws_instance" "workstation" {
    ami                         = "${var.ami-workstation}"
    availability_zone           = "${var.az}"
    instance_type               = "m3.large"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${aws_subnet.delivery.id}"
    vpc_security_group_ids      = ["${aws_security_group.automate-eval.id}"]
    associate_public_ip_address = true
    private_ip                  = "172.31.54.101"

    tags {
        "Customer" = "${var.customer}"
        "Name" = "automate-eval windows workstation"
        "TTL" = "${var.ttl}"
    }
}

resource "aws_security_group" "automate-eval" {
    description = "Enable required ports for Chef Server"
    vpc_id      = "${aws_vpc.automate-eval.id}"

    ingress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["172.31.0.0/16"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 3389
        to_port         = 3389
        protocol        = "udp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 3389
        to_port         = 3389
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 8
        to_port         = -1
        protocol        = "icmp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
      "Customer" = "${var.customer}"
      "Name" = "automate-eval security group"
      "TTL" = "${var.ttl}"
    }
}

output "chef-server" {
    value = "${aws_instance.chef-server.public_ip}"
}
output "delivery-server" {
    value = "${aws_instance.delivery-server.public_ip}"
}
output "delivery-builder-1" {
    value = "${aws_instance.delivery-builder-1.public_ip}"
}
output "workstation" {
    value = "${aws_instance.workstation.public_ip}"
}
