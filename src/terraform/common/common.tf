/* Terraform configuration to create common AWS infrastructure objects
   Copyright © 2015-2017  Basil Peace

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
  version = "~> 0.1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "eu-west-1"
}

provider "external" {
  version = "~> 0.1"
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
}
output "fidata_jenkins_iam_secret_key" {
  value = "${aws_iam_access_key.fidata_jenkins.secret}"
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

resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.fidata.id}"
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
    Name = "main"
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
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "default"
  }
}
output "default_security_group_id" {
  value = "${aws_default_security_group.default.id}"
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
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "SSH"
  }
}
output "SSH_security_group_id" {
  value = "${aws_security_group.SSH.id}"
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
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "HTTP(S)"
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
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "RDP"
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
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "SMB"
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
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "WinRM"
  }
}
output "WinRM_security_group_id" {
  value = "${aws_security_group.WinRM.id}"
}

# Key Pairs

data "external" "fidata_main_ssh_key" {
  program = [
    "bundle", "exec",
    "ruby",
    "${var.lib_dir}/get_file_contents_in_json_format.rb",
    "get",
    "${var.keys_dir}/fidata-main.pub"
  ]
}
resource "aws_key_pair" "fidata_main" {
  key_name = "fidata-main"
  public_key = "${data.external.fidata_main_ssh_key.result.contents}"
}

data "external" "fidata_jenkins_ssh_key" {
  program = [
    "bundle", "exec",
    "ruby",
    "${var.lib_dir}/get_file_contents_in_json_format.rb",
    "get",
    "${var.keys_dir}/fidata-jenkins.pub"
  ]
}
resource "aws_key_pair" "fidata_jenkins" {
  key_name = "fidata-jenkins"
  public_key = "${data.external.fidata_jenkins_ssh_key.result.contents}"
}

data "external" "kitchen_ssh_key" {
  program = [
    "bundle", "exec",
    "ruby",
    "${var.lib_dir}/get_file_contents_in_json_format.rb",
    "get",
    "${var.keys_dir}/kitchen.pub"
  ]
}
resource "aws_key_pair" "kitchen" {
  key_name = "kitchen"
  public_key = "${data.external.kitchen_ssh_key.result.contents}"
}
