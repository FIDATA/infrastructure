#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

# Berksfile for FIDATA Infrastructure
# Copyright © 2016-2017  Basil Peace
#
# CRED: Based on https://github.com/tknerr/bills-kitchen/blob/master/files/home/.vagrant.d/Vagrantfile <>
# Copyright © 2012-2015 Torben Knerr
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

Vagrant.require_version '~> 1.9'

Vagrant.configure('2') do |config|
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vbguest')

  # enable cachier globally
  unless ENV['GLOBAL_VAGRANT_CACHIER_DISABLED']

    # cache bussers, but only if we detect a test-kitchen run
    # see https://github.com/tknerr/bills-kitchen/pull/78
    if Dir.pwd.include? '.kitchen/kitchen-vagrant/'
      config.cache.auto_detect = true
      config.cache.enable(
        :generic,
        # chef_file_cache is not auto-detected as there is no chef provisioner
        # in the test-kitchen generated Vagrantfile, so we add it here
        'chef' => { cache_dir: '/tmp/kitchen/cache' },
        # for test-kitchen =< 1.3
        'busser-gemcache' => { cache_dir: '/tmp/busser/gems/cache' },
        # for test-kitchen >= 1.4
        'verifier-gemcache' => { cache_dir: '/tmp/verifier/gems/cache' }
      )

      # fix permissions
      # see https://github.com/mitchellh/vagrant/issues/2257
      # see https://github.com/test-kitchen/test-kitchen/issues/671
      config.vm.provision 'shell' do |s|
        s.env = {
          'DEBIAN_FRONTEND' => 'noninteractive'
        }
        s.inline = <<-EOF.gsub(/ ^{10}/, '')
          chown -R ubuntu:ubuntu /tmp/busser
          chown -R ubuntu:ubuntu /tmp/verifier
          chown -R ubuntu:ubuntu /tmp/kitchen
        EOF
      end
    end
  end
end
