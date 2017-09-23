#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-jenkins-slave
# Metadata
#
# Copyright © 2016-2017  Basil Peace
#
# This file is part of FIDATA Infrastructure.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

name             'fidata-jenkins-slave'
maintainer       'Basil Peace'
maintainer_email 'grv87@yandex.ru'
license          'Apache-2.0'
description      'Configures FIDATA Jenkins Slave'
version          '1.0.0'
source_url       'https://github.com/FIDATA/infrastructure/tree/src/chef/site-cookbooks/fidata-jenkins-slave'
issues_url       'https://github.com/FIDATA/infrastructure/issues'
supports         'ubuntu'
supports         'debian'
supports         'windows'
chef_version     '~> 13.3' if respond_to?(:chef_version)
depends          'fidata-build-toolkit'
