#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata_build_toolset
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

include_recipe 'home_bundle_directory::default'

execute 'choco config set webRequestTimeoutSeconds 60' if node['platform_family'] == 'windows'

if node['platform_family'] == 'windows'
  ruby_block 'refreshenv' do
    block do
      refreshenv
    end
    action :nothing
  end
end

if node['platform_family'] == 'debian'
  apt_update 'apt_update' do
    action :update
  end
end

# WORKAROUND: <grv87>
if node['platform_family'] != 'windows'
  node.default['java']['jdk_version'] = '8'
  node.default['java']['set_etc_environment'] = true
  include_recipe 'java::default'
else
  chocolatey_package 'jdk8' do
    options '--version=8.0.172 -params "source=false"'
  end
end

# WORKAROUND:
# https://github.com/chef-cookbooks/git/issues/113
# <grv87 2018-04-17>
if node['platform_family'] != 'windows'
  git_client 'default'
else
  chocolatey_package 'git.install' do
    options '-params "/NoCredentialManager /SChannel"'
  end
end

case node['platform_family']
when 'debian'
  package 'gcc'
  package 'g++'
  package 'make'
when 'windows'
  chocolatey_package 'visualstudio2017buildtools' do
    notifies :run, 'ruby_block[refreshenv]', :immediately
  end
  chocolatey_package 'visualstudio2017-workload-vctools' do
    notifies :run, 'ruby_block[refreshenv]', :immediately
  end
end

package 'gfortran' unless node['platform_family'] == 'windows'

case node['platform_family']
when 'debian'
  package 'diffutils'
when 'windows'
  chocolatey_package 'diffutils' do
    notifies :run, 'ruby_block[refreshenv]', :immediately
  end
end

case node['platform_family']
when 'fedora', 'rhel', 'freebsd', 'debian', 'mac_os_x'
  package 'gperf'
when 'windows'
  chocolatey_package 'gperf'
end

node.default['cmake']['install_method'] = node['platform_family'] != 'windows' ? 'binary' : 'package'
node.default['cmake']['version'] = '3.11.0'
include_recipe 'cmake::default'

if node['platform_family'] != 'windows'
  ruby_runtime '2' do
    provider :ruby_build
    version '2.4'
    options dev_package: true
  end
else
  chocolatey_package 'ruby' do
    options '--version=2.3.3'
    notifies :run, 'ruby_block[refreshenv]', :immediately
  end
  chocolatey_package 'ruby2.devkit' do
    notifies :run, 'ruby_block[refreshenv]', :immediately
  end
  execute 'gem install bundler'
end

execute 'bundle config specific_platform true' do
  if node['platform_family'] != 'windows'
    user node['fidata']['build-toolset']['user']
    group node['fidata']['build-toolset']['group']
  elsif ENV['USERNAME'] != node['fidata']['build-toolset']['user']
    domain node['fidata']['build-toolset']['domain']
    user node['fidata']['build-toolset']['user']
    password node['fidata']['build-toolset']['password']
  end
end

if node['platform_family'] != 'windows'
  python_runtime '3.5' do
    pip_version '9.0.3'
  end
else
  chocolatey_package 'python' do
    options '--version=3.5.4 --install-arguments="InstallAllUsers=1 CompileAll=1 Include_doc=0 Shortcuts=0 Include_dev=0 Include_tcltk=0"'
    notifies :run, 'ruby_block[refreshenv]', :immediately
  end
end

if node['platform_family'] != 'windows'
  python_package 'pipenv' do
    python '3.5' if node['platform_family'] != 'windows'
  end
else
  execute 'pip install pipenv'
end

case node['platform_family']
when 'fedora', 'rhel', 'freebsd', 'debian', 'mac_os_x'
  include_recipe 'nodejs::default'
when 'windows'
  chocolatey_package 'nodejs.install'
end

include_recipe 'perl::default'

case node['platform_family']
when 'debian'
  package 'doxygen'
when 'windows'
  chocolatey_package 'doxygen.install'
end

if node['platform_family'] != 'windows'
  include_recipe 'pandoc::default'
else
  chocolatey_package 'pandoc'
end

if node['platform_family'] != 'windows'
  include_recipe 'texlive::default'
else
  chocolatey_package 'miktex'
end

case node['platform_family']
when 'fedora', 'rhel', 'freebsd', 'debian', 'mac_os_x'
  package 'flex'
  package 'bison'
when 'windows'
  chocolatey_package 'winflexbison3'
end

case node['platform_family']
when 'fedora', 'rhel'
  package 'docbook-dtds'
  package 'docbook-style-dsssl'
  package 'docbook-style-xsl'
  package 'libxslt'
  package 'openjade'
when 'freebsd'
  package 'textproc/docbook-sgml'
  package 'textproc/docbook-xml'
  package 'textproc/docbook-xsl'
  package 'textproc/dsssl-docbook-modular'
  package 'textproc/libxslt'
  package 'textproc/openjade'
when 'debian'
  package 'docbook'
  package 'docbook-dsssl'
  package 'docbook-xsl'
  package 'libxml2-utils'
  package 'openjade1.3'
  package 'opensp'
  package 'xsltproc'
when 'mac_os_x'
  package 'docbook-dsssl'
  package 'docbook-sgml-4.2'
  package 'docbook-xml-4.2'
  package 'docbook-xsl'
  package 'libxslt'
  package 'openjade'
  package 'opensp'
when 'windows'
  chocolatey_package 'docbook-bundle'
end

include_recipe 'imagemagick::default'
if node['platform_family'] != 'windows'
  environment = Pathname.new('/etc/environment')
  convert = Pathname.new('/usr/bin/convert')
  ruby_block "Set IMCONV in #{environment}" do
    block do
      file = Chef::Util::FileEdit.new(environment)
      file.search_file_replace_line(/^IMCONV=/, "IMCONV=#{convert}")
      file.insert_line_if_no_match(/^IMCONV=/, "IMCONV=#{convert}")
      file.write_file
    end
  end
else
  # env 'IMCONV' do
  #
  # end
end
