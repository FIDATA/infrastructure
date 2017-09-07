#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-jenkins-master
# Attributes:: default
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

default['jenkins']['executor']['jvm_options'] = '-Xms256m -Xmx512m'
default['jenkins']['executor']['timeout'] = 480

default['jenkins']['master']['version'] = nil

default['jenkins']['master']['jvm_options'] = '-Xms256m -Xmx512m'

default['apache']['listen'] = ['*:80']
default['jenkins']['master']['protocol'] = 'http'
default['jenkins']['master']['server_name'] = node['fqdn']
default['jenkins']['master']['prefix'] = '/'

default['jenkins']['master']['channel'] = 'stable-2.60'
default['jenkins']['master']['plugins'] = {
  # Required plugins
  # System & Maintenance
  'mailer': '1.20',
  'github-oauth': '0.27',
  'ec2': '1.36',
  'scm-sync-configuration': '0.0.10',
  'next-build-number': '1.4',
  'support-core': '2.41',
  'lenientshutdown': '1.1.1',

  # UX
  'ansicolor': '0.5.2',
  'greenballs': '1.15',
  'chucknorris': '1.0',
  'html-audio-notifier': '0.4',

  # Primary functions
  'gradle': '1.27.1',
  'artifactory': '2.12.2',
  'openJDK-native-plugin': '1.1',
  'chef-identity': '1.0.0',
  'junit': '1.21',
  'workflow-aggregator': '2.5',
  'build-pipeline-plugin': '1.5.7.1',
  'delivery-pipeline-plugin': '1.0.4',
  'promoted-builds': '2.29.1',
  'dashboard-view': '2.9.11',
  'github': '1.28.0',
  'github-branch-source': '2.2.3',
  'github-pr-comment-build': '2.0',
  'maven-dependency-update-trigger': '1.5',
  'global-build-stats': '1.4',
  'build-timeout': '1.18',
  'violation-comments-to-github': '1.45',
  'job-dsl': '1.65',
  'managed-scripts': '1.4',

  # Dependencies
  'ace-editor': '1.1',
  'ant': '1.7',
  'authentication-tokens': '1.3',
  'aws-credentials': '1.22',
  'aws-java-sdk': '1.11.119',
  'bouncycastle-api': '2.16.2',
  'branch-api': '2.0.11',
  'cloudbees-folder': '6.1.2',
  'conditional-buildstep': '1.3.6',
  'config-file-provider': '2.16.3',
  'credentials': '2.1.15',
  'credentials-binding': '1.13',
  'display-url-api': '2.0',
  'docker-commons': '1.8',
  'docker-workflow': '1.12',
  'durable-task': '1.14',
  'git': '3.5.1',
  'git-client': '2.5.0',
  'git-server': '1.7',
  'github-api': '1.86',
  'handlebars': '1.1.1',
  'icon-shim': '2.0.3',
  'ivy': '1.27.1',
  'jackson2-api': '2.7.3',
  'javadoc': '1.4',
  'jquery': '1.11.2-0',
  'jquery-detached': '1.2.1',
  'mapdb-api': '1.0.9.0',
  'matrix-project': '1.11',
  'maven-plugin': '2.17',
  'metrics': '3.1.2.10',
  'momentjs': '1.1.1',
  'naginator': '1.17.2',
  'node-iterator-api': '1.5',
  'parameterized-trigger': '2.35.1',
  'pipeline-build-step': '2.5.1',
  'pipeline-graph-analysis': '1.5',
  'pipeline-input-step': '2.8',
  'pipeline-milestone-step': '1.3.1',
  'pipeline-model-api': '1.1.9',
  'pipeline-model-declarative-agent': '1.1.1',
  'pipeline-model-definition': '1.1.9',
  'pipeline-model-extensions': '1.1.9',
  'pipeline-rest-api': '2.9',
  'pipeline-stage-step': '2.2',
  'pipeline-stage-tags-metadata': '1.1.9',
  'pipeline-stage-view': '2.9',
  'plain-credentials': '1.4',
  'run-condition': '1.0',
  'scm-api': '2.2.1',
  'script-security': '1.34',
  'ssh-credentials': '1.13',
  'structs': '1.10',
  'subversion': '2.9',
  'token-macro': '2.3',
  'workflow-api': '2.20',
  'workflow-basic-steps': '2.6',
  'workflow-cps': '2.40',
  'workflow-cps-global-lib': '2.8',
  'workflow-durable-task-step': '2.15',
  'workflow-job': '2.12.2',
  'workflow-multibranch': '2.16',
  'workflow-scm-step': '2.6',
  'workflow-step-api': '2.12',
  'workflow-support': '2.14',
}

default['jenkins']['master']['scm_sync_configuration'].tap do |scm_sync_configuration|
  scm_sync_configuration['enabled'] = true
  scm_sync_configuration['git_repository_url'] = 'git@github.com:FIDATA/jenkins-config.git'
end

default['jenkins']['master']['security'] = 'github'
