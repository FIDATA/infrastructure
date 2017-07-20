#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-jenkins-master
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
# 	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

name             'fidata-jenkins-master'
maintainer       'Basil Peace'
maintainer_email 'grv87@yandex.ru'
license          'Apache-2.0'
description      'Configures FIDATA Jenkins Master'
version          '1.0.0'
source_url       'https://github.com/FIDATA/infrastructure/tree/src/chef/site-cookbooks/fidata-jenkins-master'
issues_url       'https://github.com/FIDATA/infrastructure/issues'
supports         'ubuntu', '>= 16.04'
chef_version     '>= 12.14' if respond_to?(:chef_version)
depends          'java', '~> 1'
depends          'apache2', '~> 5'
depends          'jenkins', '~> 5'
depends          'git', '~> 6'
depends          'ssh'
depends          'octokit'
