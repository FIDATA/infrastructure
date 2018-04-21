#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

# Gemfile for FIDATA Infrastructure
# Copyright © 2017-2018  Basil Peace
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

source 'https://fidata.jfrog.io/fidata/api/gems/gems'

# CAVEAT: We can't use just any version of Chef gem.
# Specified version should exist on Omnitruck:
# https://omnitruck.chef.io/stable/chef/versions <>
gem 'chef', '13.8.0'
gem 'knife-solo', '~> 0.6'
gem 'knife-solo_data_bag', '~> 2.1'
gem 'thor', '~> 0.19'
gem 'berkshelf', '~> 6.3'
gem 'knife-art', '~> 1.0'
gem 'rubocop', '~> 0.49'
gem 'cookstyle', '~> 2.1'
gem 'rubocop-checkstyle_formatter', '~> 0.4'
gem 'foodcritic', '~> 12.1'
gem 'test-kitchen', '~> 1.17'
gem 'kitchen-vagrant', '~> 1.2'
gem 'kitchen-ec2', '~> 2.2'
gem 'kitchen-inspec', '~> 0.19'
