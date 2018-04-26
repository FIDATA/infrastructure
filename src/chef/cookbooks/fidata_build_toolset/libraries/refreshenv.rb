#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-build-toolset
# Library:: refreshenv
#
# Copyright © 2018  Basil Peace
# CRED: Based on Chocolatey Refreshenv.cmd script <>
# Copyright (c) 2017 Chocolatey Software, Inc.
# Copyright (c) 2011 - 2017 RealDimensions Software, LLC

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

if Chef::Platform.windows?
  require 'win32/registry'

  def get_reg_env(hkey, subkey, &block)
    Win32::Registry.open(hkey, subkey) do |reg|
      reg.each_value do |name|
        value = reg.read_s_expand(name)
        if block && ENV.key?(name)
          ENV[name] = block.call(name, ENV[name], value)
        else
          ENV[name] = value
        end
      end
    end
  end

  def refreshenv
    get_reg_env(Win32::Registry::HKEY_LOCAL_MACHINE, 'System\CurrentControlSet\Control\Session Manager\Environment')
    get_reg_env(Win32::Registry::HKEY_CURRENT_USER, 'Environment') do |name, old_value, new_value|
      if name.upcase == 'PATH'
        old_value || File::PATH_SEPARATOR || new_value
      else
        new_value
      end
    end
  end
end
