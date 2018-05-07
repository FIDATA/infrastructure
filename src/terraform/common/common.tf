/* Terraform configuration to create common AWS infrastructure objects
   Copyright © 2015-2018  Basil Peace

   This file is part of FIDATA Infrastructure.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
   implied.
   See the License for the specific language governing permissions and
   limitations under the License. */

terraform {
  required_version = "~> 0.10"
  backend "artifactory" {
    url      = "https://fidata.jfrog.io/fidata"
    repo     = "terraform-state"
    subpath  = "common"
  }
}

# Variables

variable "lib_dir" {
  type = "string"
}
variable "keys_dir" {
  type = "string"
}
variable "aws_access_key" {
  type = "string"
}
variable "aws_secret_key" {
  type = "string"
}

# Providers

provider "aws" {
  version = "~> 1.0"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "eu-west-1"
}

provider "external" {
  version = "~> 1.0"
}

# IAMs

resource "aws_iam_user" "fidata_jenkins" {
  name = "fidata-jenkins"
}
resource "aws_iam_access_key" "fidata_jenkins" {
  user = "${aws_iam_user.fidata_jenkins.name}"
}
resource "aws_iam_user_policy" "fidata_jenkins" {
  name = "fidata-jenkins"
  user = "${aws_iam_user.fidata_jenkins.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1312295543082",
      "Action": [
        "ec2:DescribeSpotInstanceRequests",
        "ec2:CancelSpotInstanceRequests",
        "ec2:GetConsoleOutput",
        "ec2:RequestSpotInstances",
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeInstances",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeRegions",
        "ec2:DescribeImages",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:CreateKeyPair",
        "ec2:ImportKeyPair"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
output "fidata_jenkins_iam_access_key" {
  value = "${aws_iam_access_key.fidata_jenkins.id}"
  sensitive = true
}
output "fidata_jenkins_iam_secret_key" {
  value = "${aws_iam_access_key.fidata_jenkins.secret}"
  sensitive = true
}

# VPC

resource "aws_vpc" "fidata" {
  cidr_block = "172.31.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "FIDATA"
  }
}
output "fidata_vpc_id" {
  value = "${aws_vpc.fidata.id}"
}

resource "aws_subnet" "fidata" {
  vpc_id = "${aws_vpc.fidata.id}"
  availability_zone = "eu-west-1c"
  cidr_block = "172.31.0.0/20"
  map_public_ip_on_launch = true
  tags {
    Name = "FIDATA"
  }
}
output "fidata_subnet_id" {
  value = "${aws_subnet.fidata.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.fidata.id}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name = "eu-west-1.compute.internal"
  domain_name_servers = ["172.31.0.2"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id = "${aws_vpc.fidata.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.fidata.default_network_acl_id}"
  subnet_ids = ["${aws_subnet.fidata.id}"]
  egress {
    rule_no = 100
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }
  ingress {
    rule_no = 100
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }
  tags {
    Name = "default"
  }
}
  
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.fidata.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id = "${aws_vpc.fidata.id}"
  route_table_id = "${aws_route_table.r.id}"
}

# Security Groups

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    protocol = "icmp"
    from_port = 3
    to_port = 4
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "default_security_group_id" {
  value = "${aws_default_security_group.default.id}"
}

resource "aws_security_group" "ICMP" {
  name = "ICMP"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    protocol = "icmp"
    from_port = 8
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "icmp"
    from_port = 11
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "ICMP_security_group_id" {
  value = "${aws_security_group.ICMP.id}"
}

resource "aws_security_group" "ICMP_private" {
  name = "ICMP_private"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    protocol = "icmp"
    from_port = 8
    to_port = 0
    cidr_blocks = ["${aws_vpc.fidata.cidr_block}"]
  }
  ingress {
    protocol = "icmp"
    from_port = 11
    to_port = 0
    cidr_blocks = ["${aws_vpc.fidata.cidr_block}"]
  }
}
output "ICMP_private_security_group_id" {
  value = "${aws_security_group.ICMP_private.id}"
}

resource "aws_security_group" "SSH" {
  name = "SSH"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "SSH_security_group_id" {
  value = "${aws_security_group.SSH.id}"
}

resource "aws_security_group" "SSH_private" {
  name = "SSH_private"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.fidata.cidr_block}"]
  }
}
output "SSH_private_security_group_id" {
  value = "${aws_security_group.SSH_private.id}"
}

resource "aws_security_group" "HTTP_S" {
  name = "HTTP(S)"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8
    to_port = 8
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "HTTP_S_security_group_id" {
  value = "${aws_security_group.HTTP_S.id}"
}

resource "aws_security_group" "RDP" {
  name = "RDP"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "RDP_security_group_id" {
  value = "${aws_security_group.RDP.id}"
}

resource "aws_security_group" "SMB" {
  name = "SMB"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 445
    to_port = 445
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "SMB_security_group_id" {
  value = "${aws_security_group.SMB.id}"
}

resource "aws_security_group" "WinRM" {
  name = "WinRM"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 5985
    to_port = 5985
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5986
    to_port = 5986
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "WinRM_security_group_id" {
  value = "${aws_security_group.WinRM.id}"
}

resource "aws_security_group" "WinRM_private" {
  name = "WinRM_private"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 5985
    to_port = 5985
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.fidata.cidr_block}"]
  }
  ingress {
    from_port = 5986
    to_port = 5986
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.fidata.cidr_block}"]
  }
}
output "WinRM_private_security_group_id" {
  value = "${aws_security_group.WinRM_private.id}"
}

resource "aws_security_group" "JNLP" {
  name = "JNLP"
  vpc_id = "${aws_vpc.fidata.id}"
  ingress {
    from_port = 49817
    to_port = 49817
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.fidata.cidr_block}"]
  }
}
output "JNLP_security_group_id" {
  value = "${aws_security_group.JNLP.id}"
}

# Key Pairs

data "external" "fidata_main_ssh_key" {
  program = [
    "bundle", "exec",
    "ruby",
    "${var.lib_dir}/get_file_content_in_json_format.rb",
    "get",
    "${var.keys_dir}/fidata-main.pub"
  ]
}
resource "aws_key_pair" "fidata_main" {
  key_name = "fidata-main"
  public_key = "${data.external.fidata_main_ssh_key.result.content}"
}

data "external" "fidata_jenkins_ssh_key" {
  program = [
    "bundle", "exec",
    "ruby",
    "${var.lib_dir}/get_file_content_in_json_format.rb",
    "get",
    "${var.keys_dir}/fidata-jenkins.pub"
  ]
}
resource "aws_key_pair" "fidata_jenkins" {
  key_name = "fidata-jenkins"
  public_key = "${data.external.fidata_jenkins_ssh_key.result.content}"
}

data "external" "kitchen_ssh_key" {
  program = [
    "bundle", "exec",
    "ruby",
    "${var.lib_dir}/get_file_content_in_json_format.rb",
    "get",
    "${var.keys_dir}/kitchen.pub"
  ]
}
resource "aws_key_pair" "kitchen" {
  key_name = "kitchen"
  public_key = "${data.external.kitchen_ssh_key.result.content}"
}
