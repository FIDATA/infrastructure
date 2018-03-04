#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-build-toolset
# Attributes:: default
#
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

default['fidata'].tap do |fidata|
  fidata['build-toolset'].tap do |build_toolset|
    build_toolset['user'] = case node['platform']
                            when 'ubuntu' then 'ubuntu'
                            end
    build_toolset['group'] = case node['platform']
                             when 'ubuntu' then 'ubuntu'
                             end
  end
end
