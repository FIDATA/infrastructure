#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-jenkins-slave
# Recipe:: default
#
# Copyright © 2015-2018  Basil Peace
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

directory node['etc']['passwd'][node['fidata']['build-toolset']['user']]['dir'] do
  mode '0700'
end

include_recipe 'fidata-build-toolset::default'

directory '/srv/jenkins' do
  user node['fidata']['build-toolset']['user']
  group node['fidata']['build-toolset']['user']
  recursive true
  mode '0700'
  action :create
end
