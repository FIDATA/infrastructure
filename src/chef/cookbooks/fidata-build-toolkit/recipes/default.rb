#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-build-toolkit
# Recipe:: default
#
# Copyright © 2015-2017  Basil Peace
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

if node['platform_family'] == 'debian'
  apt_update 'apt_update' do
    action :update
  end
end

node.default['java']['jdk_version'] = '8'
node.default['java']['accept_oracle_download_terms'] = true
node.default['java']['set_etc_environment'] = true
include_recipe 'java::default'

git_client 'default' do
  action :install
end

case node['platform_family']
when 'debian'
  package 'gcc'
  package 'g++'
  package 'make'
when 'windows'
  chocolatey_package 'vcbuildtools' do
    options '-ia "/InstallSelectableItems Win81SDK_CppBuildSKUV1"'
  end
end

package 'gfortran' unless node['platform_family'] == 'windows'

case node['platform_family']
when 'debian'
  package 'diffutils'
when 'windows'
  chocolatey_package 'diffutils'
end

package 'gperf' unless node['platform_family'] == 'windows'

node.default['cmake']['install_method'] = 'binary'
node.default['cmake']['version'] = '3.9.1'
include_recipe 'cmake::default'

ruby_runtime '2' do
  version '2.3'
  options dev_package: true
end
home_directory = node['etc']['passwd'][node['fidata']['build-toolkit']['user']]['dir']
gem_home = "#{home_directory}/.gems"
directory gem_home do
  action :create
end
unless node['platform_family'] == 'windows'
  ruby_block 'Set GEM_HOME in user\'s profile' do
    block do
      filename = "#{home_directory}/.pam_environment"
      Resource::File.new(filename, run_context).tap do |file|
        file.owner node['fidata']['build-toolkit']['user']
        file.group node['fidata']['build-toolkit']['group']
        file.mode '0644'
        file.run_action :create_if_missing
      end
      Chef::Util::FileEdit.new(filename).tap do |file|
        file.search_file_replace_line(/^GEM_HOME=/, "GEM_HOME=#{gem_home}")
        file.insert_line_if_no_match(/^GEM_HOME=/, "GEM_HOME=#{gem_home}")
        file.write_file
      end
    end
  end
end

python_runtime '3.5' do
  pip_version '9.0.1'
end
python_package 'pipenv' do
  python '3.5'
end

include_recipe 'perl::default'

case node['platform_family']
when 'debian'
  package 'doxygen'
when 'windows'
  chocolatey_package 'doxygen.install'
end

include_recipe 'pandoc::default'

include_recipe 'texlive::default'

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
end

include_recipe 'imagemagick::default'
unless node['platform_family'] == 'windows'
  ruby_block 'Set IMCONV in /etc/environment' do
    block do
      file = Chef::Util::FileEdit.new('/etc/environment')
      file.search_file_replace_line(/^IMCONV=/, 'IMCONV=/usr/bin/convert')
      file.insert_line_if_no_match(/^IMCONV=/, 'IMCONV=/usr/bin/convert')
      file.write_file
    end
  end
end
