/* Terraform configuration to deploy instances
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
    subpath  = "instances"
  }
}

# Variables

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

provider "aws" {
  version = "~> 1.0"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "eu-west-1"
}

provider "cloudflare" {
  version = "~> 0.1"
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

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.fidata.id}"
  filter = {
    name = "group-name"
    values = ["default"]
  }
}

data "aws_security_group" "ICMP" {
  vpc_id = "${data.aws_vpc.fidata.id}"
  filter = {
    name = "group-name"
    values = ["ICMP"]
  }
}

data "aws_security_group" "SSH" {
  vpc_id = "${data.aws_vpc.fidata.id}"
  filter = {
    name = "group-name"
    values = ["SSH"]
  }
}

data "aws_security_group" "HTTP_S" {
  vpc_id = "${data.aws_vpc.fidata.id}"
  filter = {
    name = "group-name"
    values = ["HTTP(S)"]
  }
}

# Immutable AMIs

data "aws_ami" "JenkinsMaster" {
  filter {
    name   = "name"
    values = ["JenkinsMaster-production-*"]
  }
  filter {
    name   = "tag:version"
    values = ["4.0.0"]
  }
  owners     = ["self"]
}

# Instances

resource "aws_instance" "jenkins_master" {
  ami = "${data.aws_ami.JenkinsMaster.metadata_full.region-eu-west-1}"
  subnet_id = "${data.aws_subnet.fidata.id}"
  instance_type = "t2.small"
  root_block_device {
    volume_type = "standard"
    volume_size = 8
  }
  vpc_security_group_ids = [
    "${data.aws_security_group.default.id}",
    "${data.aws_security_group.ICMP.id}",
    "${data.aws_security_group.HTTP_S.id}"
  ]
  key_name = "fidata-main"
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

resource "cloudflare_record" "spf_txt" {
  domain = "fidata.org"
  name = "@"
  type = "TXT"
  value = "v=spf1 redirect=_spf.yandex.net"
}

resource "cloudflare_record" "spf" {
  domain = "fidata.org"
  name = "@"
  type = "SPF"
  value = "v=spf1 redirect=_spf.yandex.net"
}

resource "cloudflare_record" "github_verify_domain" {
  domain = "fidata.org"
  name = "_github-challenge-FIDATA.fidata.org."
  type = "TXT"
  value = "34336fee0d"
}

resource "cloudflare_record" "website_ru" {
  domain = "fidata.ru"
  name = "fidata.ru"
  type = "CNAME"
  value = "fidata.org."
  proxied = true
}

resource "cloudflare_record" "www_ru" {
  domain = "fidata.ru"
  name = "www"
  type = "CNAME"
  value = "fidata.org."
  proxied = true
}
