/* Terraform configuration to deploy instances
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

# Variables

variable "atlas_token" {
  type = "string"
}
variable "aws_access_key" {
  type = "string"
}
variable "aws_secret_key" {
  type = "string"
}
variable "cloudflare_email" {
  type = "string"
}
variable "cloudflare_token" {
  type = "string"
}

# Providers

provider "atlas" {
  version = ">= 0.1"
  token = "${var.atlas_token}"
}

provider "aws" {
  version = ">= 0.1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "eu-west-1"
}

provider "cloudflare" {
  version = ">= 0.1"
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

# VPC and security groups

data "aws_vpc" "fidata" {
  filter = {
    name = "tag:Name"
    values = ["FIDATA"]
  }
}

data "aws_subnet" "fidata" {
  vpc_id = "${data.aws_vpc.fidata.id}"
  filter = {
    name = "availabilityZone"
    values = ["eu-west-1c"]
  }
}

data "aws_security_group" "SSH" {
  vpc_id = "${data.aws_vpc.fidata.id}"
  filter = {
    name = "tag:Name"
    values = ["SSH"]
  }
}

data "aws_security_group" "HTTP_S" {
  vpc_id = "${data.aws_vpc.fidata.id}"
  filter = {
    name = "tag:Name"
    values = ["HTTP(S)"]
  }
}

# Immutable AMIs

data "atlas_artifact" "JenkinsMasterAMI" {
  name = "fidata/JenkinsMaster"
  type = "amazon.image"
  version = "latest"
}

# Instances

resource "aws_instance" "jenkins_master" {
  ami = "${data.atlas_artifact.JenkinsMasterAMI.metadata_full.region-eu-west-1}"
  subnet_id = "${data.aws_subnet.fidata.id}"
  instance_type = "t2.small"
  root_block_device {
    volume_type = "standard"
    volume_size = 8
  }
  vpc_security_group_ids = [
    "${data.aws_security_group.HTTP_S.id}"
  ]
  tags {
    Name = "FIDATA Jenkins Master"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IPs

resource "aws_eip" "jenkins_master" {
  instance = "${aws_instance.jenkins_master.id}"
  vpc = true
}

# DNS

resource "cloudflare_record" "website" {
  domain = "fidata.org"
  name = "fidata.org"
  type = "CNAME"
  value = "fidata.github.io."
  proxied = true
}

resource "cloudflare_record" "www" {
  domain = "fidata.org"
  name = "www"
  type = "CNAME"
  value = "fidata.github.io."
  proxied = true
}

resource "cloudflare_record" "ajaxhttpheaders" {
  domain = "fidata.org"
  name = "ajaxhttpheaders"
  type = "CNAME"
  value = "ghs.googlehosted.com." 
  proxied = true
}

resource "cloudflare_record" "jenkins" {
  domain = "fidata.org"
  name = "jenkins"
  type = "A"
  value = "${aws_eip.jenkins_master.public_ip}"
  proxied = true
}

resource "cloudflare_record" "artifactory" {
  domain = "fidata.org"
  name = "artifactory"
  type = "CNAME"
  value = "fidata.jfrog.io."
  proxied = true
}

resource "cloudflare_record" "google_verification" {
  domain = "fidata.org"
  name = "fidata.org"
  type = "TXT"
  value = "google-site-verification=psnXZZeicyuiPxDaBDb37QCl2k90-wV4lJrg6NOpIs0"
  ttl = 3600
}

resource "cloudflare_record" "yandex_mail_verification" {
  domain = "fidata.org"
  name = "yamail-bde06f1e7c17"
  type = "CNAME"
  value = "mail.yandex.ru."
  proxied = false
}

resource "cloudflare_record" "mail" {
  domain = "fidata.org"
  name = "fidata.org"
  type = "MX"
  value = "mx.yandex.net."
  priority = 10
}

resource "cloudflare_record" "yandex_mail_dkim" {
  domain = "fidata.org"
  name = "mail._domainkey"
  type = "TXT"
  value = "v=DKIM1; k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCtZQIP0/9gZXNCT/UCY1HA2cBn/42wZfEVc2Z0gebYAnj6KiUf80OitmNkn72WEyDJmppEa/X6sNpRonSOJGer4nz92sjvaMIaI2JXCiw5/aefAVA1V54UMmvpQMtcfe70pcRpZW4ZHwVJnb+HhNzjZZtCThIsQyu/3/bKEUeYJwIDAQAB"
}
