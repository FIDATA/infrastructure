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
#     http://www.apache.org/licenses/LICENSE-2.0
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

default['jenkins']['master']['channel'] = 'stable-2.89'
default['jenkins']['master']['plugins'] = {
  # Required plugins
  # System & Maintenance
  'mailer': '1.20',
  'github-oauth': '0.28.1',
  'ec2': '1.37',
  'windows-slaves': '1.3.1',
  'scm-sync-configuration': '0.0.10',
  'next-build-number': '1.5',
  'support-core': '2.42',
  'lenientshutdown': '1.1.1',

  # UX
  'ansicolor': '0.5.2',
  'dashboard-view': '2.9.11',
  'pegdown-formatter': '1.3',
  'greenballs': '1.15',
  'html-audio-notifier': '0.4',
  'chucknorris': '1.0',

  # Primary functions - jobs as code
  'job-dsl': '1.66',
  'managed-scripts': '1.4',
  # Primary functions - workflows
  'workflow-aggregator': '2.5',
  'delivery-pipeline-plugin': '1.0.7',
  'promoted-builds': '2.31',
  'blueocean': '1.3.2',
  # Primary functions - VCSs and ITSs
  'github': '1.28.1',
  'github-branch-source': '2.3.1',
  'github-pr-comment-build': '2.0',
  'violation-comments-to-github': '1.48',
  'pipeline-github': '1.0',
  # Primary functions - triggers
  'maven-dependency-update-trigger': '1.5',
  # Primary functions - build tools
  'gradle': '1.28',
  # Primary functions - SDKs
  'openJDK-native-plugin': '1.1',
  # Primary functions - documentation
  'javadoc': '1.4',
  # Primary functions - code quality
  'checkstyle': '3.49',
  'warnings': '4.63',
  'junit': '1.21',
  'htmlpublisher': '1.14',
  # Primary functions - releases
  'artifactory': '2.13.1',
  'chef-identity': '1.0.0',
  # Primary functions - auxiliary
  'global-build-stats': '1.5',
  'build-timeout': '1.19',

  # Dependencies
  'ace-editor': '1.1',
  'analysis-core': '1.92',
  'ant': '1.7',
  'antisamy-markup-formatter': '1.5',
  'apache-httpcomponents-client-4-api': '4.5.3-2.0',
  'authentication-tokens': '1.3',
  'aws-credentials': '1.23',
  'aws-java-sdk': '1.11.226',
  'blueocean-autofavorite': '1.0.0',
  'blueocean-bitbucket-pipeline': '1.3.2',
  'blueocean-commons': '1.3.2',
  'blueocean-config': '1.3.2',
  'blueocean-dashboard': '1.3.2',
  'blueocean-display-url': '2.1.1',
  'blueocean-events': '1.3.2',
  'blueocean-git-pipeline': '1.3.2',
  'blueocean-github-pipeline': '1.3.2',
  'blueocean-i18n': '1.3.2',
  'blueocean-jira': '1.3.2',
  'blueocean-jwt': '1.3.2',
  'blueocean-personalization': '1.3.2',
  'blueocean-pipeline-api-impl': '1.3.2',
  'blueocean-pipeline-editor': '1.3.2',
  'blueocean-pipeline-scm-api': '1.3.2',
  'blueocean-rest': '1.3.2',
  'blueocean-rest-impl': '1.3.2',
  'blueocean-web': '1.3.2',
  'bouncycastle-api': '2.16.2',
  'branch-api': '2.0.15',
  'cloudbees-bitbucket-branch-source': '2.2.7',
  'cloudbees-folder': '6.2.1',
  'conditional-buildstep': '1.3.6',
  'config-file-provider': '2.16.4',
  'credentials': '2.1.16',
  'credentials-binding': '1.13',
  'display-url-api': '2.1.0',
  'docker-commons': '1.9',
  'docker-workflow': '1.14',
  'durable-task': '1.15',
  'favorite': '2.3.1',
  'git': '3.6.4',
  'git-client': '2.6.0',
  'git-server': '1.7',
  'github-api': '1.90',
  'handlebars': '1.1.1',
  'icon-shim': '2.0.3',
  'ivy': '1.28',
  'jackson2-api': '2.8.7.0',
  'jira': '2.5',
  'jquery': '1.12.4-0',
  'jquery-detached': '1.2.1',
  'jsch': '0.1.54.1',
  'mapdb-api': '1.0.9.0',
  'matrix-project': '1.12',
  'maven-plugin': '3.0',
  'mercurial': '2.2',
  'metrics': '3.1.2.10',
  'momentjs': '1.1.1',
  'naginator': '1.17.2',
  'node-iterator-api': '1.5',
  'parameterized-trigger': '2.35.2',
  'pipeline-build-step': '2.5.1',
  'pipeline-graph-analysis': '1.5',
  'pipeline-input-step': '2.8',
  'pipeline-milestone-step': '1.3.1',
  'pipeline-model-api': '1.2.4',
  'pipeline-model-declarative-agent': '1.1.1',
  'pipeline-model-definition': '1.2.4',
  'pipeline-model-extensions': '1.2.4',
  'pipeline-rest-api': '2.9',
  'pipeline-stage-step': '2.3',
  'pipeline-stage-tags-metadata': '1.2.4',
  'pipeline-stage-view': '2.9',
  'plain-credentials': '1.4',
  'pubsub-light': '1.12',
  'run-condition': '1.0',
  'scm-api': '2.2.5',
  'script-security': '1.35',
  'sse-gateway': '1.15',
  'ssh-credentials': '1.13',
  'structs': '1.10',
  'subversion': '2.9',
  'token-macro': '2.3',
  'variant': '1.1',
  'workflow-api': '2.23.1',
  'workflow-basic-steps': '2.6',
  'workflow-cps': '2.41',
  'workflow-cps-global-lib': '2.9',
  'workflow-durable-task-step': '2.17',
  'workflow-job': '2.15',
  'workflow-multibranch': '2.16',
  'workflow-scm-step': '2.6',
  'workflow-step-api': '2.13',
  'workflow-support': '2.16',
}

default['jenkins']['master']['scm_sync_configuration'].tap do |scm_sync_configuration|
  scm_sync_configuration['enabled'] = true
  scm_sync_configuration['git_repository_url'] = 'git@github.com:FIDATA/jenkins-config.git'
end

default['jenkins']['master']['security'] = 'github'

default['jenkins']['master']['endpoint'] = "http://#{node['jenkins']['master']['host']}:#{node['jenkins']['master']['port']}"
