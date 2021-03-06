/* Terraform configuration to get artifact metadata from Atlas
   Copyright © 2017  Basil Peace

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

variable "atlas_token" {
  type = "string"
}
variable "name" {
  type = "string"
}
variable "type" {
  type = "string"
}
variable "version" {
  type = "string"
}

provider "atlas" {
  version = "~> 0.1"
  token = "${var.atlas_token}"
}

data "atlas_artifact" "atlas_artifact" {
  name = "${var.name}"
  type = "${var.type}"
  metadata {
    version = "${var.version}"
  }
}
output "metadata_full" {
  value = "${data.atlas_artifact.atlas_artifact.metadata_full}"
}
