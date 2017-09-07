#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: fidata-jenkins-master
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
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# CAVEAT:
# This recipe is written as non-idempotent. It will most likely fail
# on the second run
# To make it idempotent the following tasks should be accomplished:
#   * Revert applied security
#   * Rewrite groovy script using construction like this:
#     if (!securityRealm.equals(instance.getSecurityRealm())) {
#       ... // change value
#       instance.save()
#     }
# <>

node.default.tap do |default|
  default['fidata'].tap do |fidata|
    fidata['chef'] = data_bag_item('runtime', 'FIDATAChef').to_hash
    fidata['jenkins'] = data_bag_item('default', 'FIDATAJenkins').to_hash
    fidata['jenkins'].merge! data_bag_item('runtime', 'FIDATAJenkins').to_hash
  end
  default['jenkins'].tap do |jenkins|
    jenkins['github_oauth'] = data_bag_item('runtime', 'JenkinsGithubOAuth').to_hash
    jenkins['ec2_cloud'] = data_bag_item('runtime', 'JenkinsEC2Cloud').to_hash
  end
  default['release_credentials'] = data_bag_item('runtime', 'ReleaseCredentials').to_hash
end

# Apt update

apt_update 'apt_update' do
  action :update
end

# Install JDK

node.default['java'].tap do |java|
  java['jdk_version'] = '8'
  java['accept_oracle_download_terms'] = true
end
include_recipe 'java::default'

# Install and configure Apache HTTPD

include_recipe 'apache2::default'

apache_module 'proxy'
apache_module 'proxy_http'
apache_module 'headers'

web_app 'jenkins' do
  template 'jenkins.conf.erb'
  server_admin node['fidata']['jenkins']['email']
  server_name node['jenkins']['master']['server_name']
  prefix node['jenkins']['master']['prefix']
  proxy_port node['jenkins']['master']['port']
  notifies :restart, 'service[apache2]', :immediately
end

# Install Jenkins

node.default['jenkins'].tap do |jenkins|
  jenkins['executor']['protocol'] = 'remoting'
  jenkins['master'].tap do |master|
    master['install_method'] = 'package'
    master['jenkins_args'] = [
      master['jenkins_args'],
      "--prefix=#{node['jenkins']['master']['prefix']}",
    ].compact.join(' ')
  end
end

node.run_state.tap do |run_state|
  run_state[:jenkins_username] = node['fidata']['chef']['username'] # ~FC001
  run_state[:jenkins_password] = node['fidata']['chef']['jenkins']['password'] # ~FC001
  run_state[:jenkins_private_key] = nil # ~FC001
end

include_recipe 'jenkins::master'

jenkins_command 'safe-restart' do
  action :nothing
end

# Install and configure Git

git_client 'default' do
  action :install
end

git_config 'user.name' do
  user node['jenkins']['master']['user']
  scope 'global'
  value node['fidata']['jenkins']['full_name']
  action :set
end

git_config 'user.email' do
  user node['jenkins']['master']['user']
  scope 'global'
  value node['fidata']['jenkins']['email']
  action :set
end

# Configure SSH

ssh_dir = "#{node['jenkins']['master']['home']}/.ssh"

directory ssh_dir do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0700'
  action :create
end

# Upload SSH key to the node and Github

ssh_private_key_file = "#{ssh_dir}/id_rsa"
file 'ssh_private_key' do
  content node['fidata']['jenkins']['private_key'].chomp
  path ssh_private_key_file
  sensitive true
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0600'
  action :create
end
file 'ssh_public_key' do
  content node['fidata']['jenkins']['public_key']
  path "#{ssh_private_key_file}.pub"
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0600'
  action :create
end

github_user_key 'id_rsa' do
  login node['fidata']['jenkins']['email']
  password node['fidata']['jenkins']['github']['token']
  title 'id_rsa'
  key node['fidata']['jenkins']['public_key'].chomp
  action :create_or_replace
end

ssh_known_hosts 'github.com' do
  user node['jenkins']['master']['user']
  hashed true
  action :add
end

# Turn off scm-sync-configuration plugin

plugins_directory = "#{node['jenkins']['master']['home']}/plugins"
directory plugins_directory do
  user node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0755'
  action :create
end

scm_sync_configuration_disabled_file = "#{plugins_directory}/scm-sync-configuration.jpi.disabled" # "#{run_context.resource_collection.find(jenkins_plugin: 'scm-sync-configuration').provider_for_action(:install).plugin_file}.disabled"
file scm_sync_configuration_disabled_file do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0644'
  action :create
end

# Bootstrap security

cookbook_file 'jenkins.install.UpgradeWizard.state' do
  source 'jenkins.install.UpgradeWizard.state'
  path "#{node['jenkins']['master']['home']}/jenkins.install.UpgradeWizard.state"
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0644'
  action :create_if_missing
end

cookbook_file 'jenkins.install.InstallUtil.lastExecVersion' do
  source 'jenkins.install.InstallUtil.lastExecVersion'
  path "#{node['jenkins']['master']['home']}/jenkins.install.InstallUtil.lastExecVersion"
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0644'
  action :create_if_missing
end

init_scripts_dir = "#{node['jenkins']['master']['home']}/init.groovy.d"

directory 'init_scripts_dir' do
  path init_scripts_dir
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  action :nothing
end

template 'bootstrap-security.groovy' do
  source 'bootstrap-security.groovy.erb'
  variables(
    admin_username: node['fidata']['chef']['username'],
    admin_password: node['fidata']['chef']['jenkins']['password'],
  )
  path "#{init_scripts_dir}/bootstrap-security.groovy"
  sensitive true
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0700'
  notifies :create, 'directory[init_scripts_dir]', :before
  action :nothing
end

ruby_block 'bootstrap_security' do
  block do
    run_context.resource_collection.find(directory: 'init_scripts_dir').run_action :create
    run_context.resource_collection.find(template: 'bootstrap-security.groovy').run_action :create
    run_context.resource_collection.find(service: 'jenkins').run_action :restart
  end
  action :run
end

# Install plugins

node['jenkins']['master']['plugins'].each do |plugin, version|
  jenkins_plugin plugin do
    version version
    install_deps false
    action :install
  end
end

file 'jenkins-plugins-last-state' do
  path "#{Chef::Config[:file_cache_path]}/jenkins-plugins-last-state"
  content node['jenkins']['master']['plugins'].map { |k, v| "#{k}:#{v}" }.sort.join("\n")
  notifies :execute, 'jenkins_command[safe-restart]', :immediately
  action :create
end

# Create FIDATA Jenkins credentials

# Github credentials
# for github plugin
jenkins_secret_text_credentials 'github' do
  id 'Github'
  description 'FIDATA Jenkins - Github'
  secret node['fidata']['jenkins']['github']['token']
  action :create
end
# for github-branch-source plugin
jenkins_password_credentials 'github' do
  id 'Github 2'
  description 'FIDATA Jenkins - Github'
  username node['fidata']['jenkins']['username']
  password node['fidata']['jenkins']['github']['token']
  action :create
end

# Artifactory credentials for artifactory plugin
jenkins_password_credentials 'artifactory' do
  id 'Artifactory'
  description 'FIDATA Jenkins - Artifactory'
  username node['fidata']['jenkins']['username']
  password node['fidata']['jenkins']['artifactory']['api_key']
  action :create
end

# AWS credentials for ec2 plugin
jenkins_aws_credentials 'fidata_jenkins' do
  id 'AWS'
  description 'FIDATA Jenkins AWS'
  access_key node['fidata']['jenkins']['aws_iam']['access_key']
  secret_key node['fidata']['jenkins']['aws_iam']['secret_key']
  action :create
end

# Create release credentials

# Gradle Plugins
jenkins_password_credentials 'gradle_plugins' do
  id 'Gradle Plugins'
  description 'Release - Gradle Plugins'
  username node['release_credentials']['gradle_plugins']['key']
  password node['release_credentials']['gradle_plugins']['secret']
  action :create
end

# Chef Supermarket
jenkins_script 'chef_identity' do
  command <<~EOF
    import jenkins.model.Jenkins
    import io.chef.jenkins.ChefIdentityBuildWrapper
    import io.chef.jenkins.ChefIdentity

    Jenkins instance = Jenkins.getInstance()

    ChefIdentityBuildWrapper.DescriptorImpl chefIdentityDescriptor = instance.getDescriptor(ChefIdentityBuildWrapper.class)

    List<ChefIdentity> chefIdentities = [new ChefIdentity(
      /* idName */ 'Chef Identity',
      /* pemKey */ '''#{node['release_credentials']['chef_id']['private_key'].chomp}''',
      /* knifeRb */ 'client_key \\'./user.pem\\''
    )]

    chefIdentityDescriptor.setChefIdentities(chefIdentities)
    chefIdentityDescriptor.save()
  EOF
  action :execute
end

# Chocolatey
jenkins_secret_text_credentials 'chocolatey' do
  id 'Chocolatey'
  description 'Release - Chocolatey'
  secret node['release_credentials']['chocolatey']['api_key']
  action :create
end

# Manually reload Jenkins configuration from git repository
# CRED: This code is based on the code of Jenkins SCM Sync Configuration Plugin
# Licensed under the MIT License
# Copyright (c) 2010-, Frédéric Camblor
# <>

WORKING_DIRECTORY = 'scm-sync-configuration'
CHECKOUT_SCM_DIRECTORY = 'checkoutConfiguration'

scm_sync_configuration_working_directory = "#{node['jenkins']['master']['home']}/#{WORKING_DIRECTORY}"
directory scm_sync_configuration_working_directory do
  user node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0755'
  action :create
end

scm_sync_configuration_checkout_scm_directory = "#{scm_sync_configuration_working_directory}/#{CHECKOUT_SCM_DIRECTORY}"

git 'scm_sync_configuration' do
  repository node['jenkins']['master']['scm_sync_configuration']['git_repository_url']
  remote 'origin'
  revision 'master'
  destination scm_sync_configuration_checkout_scm_directory
  checkout_branch 'master'
  enable_checkout false
  depth 1
  user node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  notifies :run, 'ruby_block[scm_sync_configuration_reload_all_files_from_scm]', :immediately
  action :sync
end

ruby_block 'scm_sync_configuration_reload_all_files_from_scm' do # ~FC014
  block do
    Dir.chdir(scm_sync_configuration_checkout_scm_directory) do
      Dir.glob(['**/*']).each do |f|
        next if f == '.git'
        new_relative = "#{node['jenkins']['master']['home']}/#{f}"
        Resource::Directory.new(new_relative, run_context).tap do |r|
          r.owner node['jenkins']['master']['user']
          r.group node['jenkins']['master']['group']
          r.mode '0755'
          r.run_action :create
        end if File.directory?(f)
        Resource::File.new(new_relative, run_context).tap do |r|
          r.owner node['jenkins']['master']['user']
          r.group node['jenkins']['master']['group']
          r.mode '0644'
          r.content IO.read(f, mode: 'rb')
          r.run_action :create
        end if File.file?(f)
      end
    end
  end
  action :nothing
end

# Enable CLI over Remoting

template 'enable_jenkins_cli_over_remoting' do
  source 'jenkins.CLI.xml.erb'
  variables(
    enabled: true,
  )
  path "#{node['jenkins']['master']['home']}/jenkins.CLI.xml"
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0644'
  action :create
end

# Turn off executors on master

jenkins_script 'turn_off_executors_on_master' do
  command <<~EOF
    import jenkins.model.Jenkins

    Jenkins instance = Jenkins.getInstance()

    instance.setNumExecutors(0)

    instance.save()
  EOF
end

# Configure mailer plugin

jenkins_script 'configure_mailer_plugin' do
  command <<~EOF
    import jenkins.model.Jenkins
    import jenkins.model.JenkinsLocationConfiguration
    import hudson.tasks.Mailer

    JenkinsLocationConfiguration jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()

    String url = '#{node['jenkins']['master']['protocol']}://#{node['jenkins']['master']['server_name']}#{':' + node['jenkins']['master']['server_port'].to_s unless node['jenkins']['master']['server_port'].nil?}#{node['jenkins']['master']['prefix']}'
    String adminAddress = '#{node['fidata']['jenkins']['full_name']} <#{node['fidata']['jenkins']['email']}>'

    jenkinsLocationConfiguration.setUrl(url)
    jenkinsLocationConfiguration.setAdminAddress(adminAddress)
    jenkinsLocationConfiguration.save()

    Jenkins instance = Jenkins.getInstance()

    Mailer.DescriptorImpl mailerDescriptor = instance.getDescriptor('hudson.tasks.Mailer')

    String smtpUser = '#{node['fidata']['jenkins']['yandex']['username']}'
    String smtpPassword = '#{node['fidata']['jenkins']['yandex']['password']}'
    String smtpHost = 'smtp.yandex.ru'
    String smtpPort = '465'
    boolean useSsl = true
    String charset = 'UTF-8'

    mailerDescriptor.setSmtpAuth(smtpUser, smtpPassword)
    mailerDescriptor.setSmtpHost(smtpHost)
    mailerDescriptor.setSmtpPort(smtpPort)
    mailerDescriptor.setUseSsl(useSsl)
    mailerDescriptor.setCharset(charset)
    mailerDescriptor.save()
  EOF
  action :execute
end

# Configure git plugin

jenkins_script 'configure_git_plugin' do
  command <<~EOF
    import jenkins.model.Jenkins
    import hudson.plugins.git.GitSCM

    Jenkins instance = Jenkins.getInstance()

    GitSCM.DescriptorImpl gitScmDescriptor = instance.getDescriptor('hudson.plugins.git.GitSCM')

    String globalConfigName = '#{node['fidata']['jenkins']['full_name']}'
    String globalEmail = '#{node['fidata']['jenkins']['email']}'

    gitScmDescriptor.setGlobalConfigName(globalConfigName)
    gitScmDescriptor.setGlobalConfigEmail(globalEmail)
    gitScmDescriptor.save()
  EOF
  action :execute
end

# Configure amazon-ec2 plugin

slave_templates = []

node['jenkins']['ec2_cloud']['slaves'].each do |name, slave|
  type_data = slave['type_data']
  ami_type = case type_data['type']
             when 'unix'
               <<~EOF
                 UnixData(
                   /*rootCommandPrefix*/ '#{type_data['root_сommand_prefix']}',
                   /*sshPort*/ '22'
                 )
               EOF
             when 'windows'
               <<~EOF
                 WindowsData(
                   /*password*/ '#{type_data['password']}',
                   /*useHTTPS*/ false,
                   /*bootDelay*/ '180'
                 )
               EOF
             end
  slave_templates << <<~EOF
    new SlaveTemplate(
      /*ami*/ '#{slave['ami']}',
      /*zone*/ '#{node['jenkins']['ec2_cloud']['zone']}',
      /*spotConfig*/ null,
      /*securityGroups*/ '#{slave['security_groups'].join(' ')}',
      /*remoteFS*/ '#{slave['remote_fs']}',
      /*type*/ InstanceType.T2Medium,
      /*ebsOptimized*/ false,
      /*labelString*/ '#{slave['labels'].join(' ')}',
      /*mode*/ Node.Mode.#{slave['mode']},
      /*description*/ '#{name}',
      /*initScript*/ '',
      /*tmpDir*/ '',
      /*userData*/ '',
      /*numExecutors*/ '2',
      /*remoteAdmin*/ '#{slave['remote_admin']}',
      /*amiType*/ new #{ami_type},
      /*jvmopts*/ '',
      /*stopOnTerminate*/ false,
      /*subnetId*/ '#{node['jenkins']['ec2_cloud']['subnet_id']}',
      /*tags*/ null,
      /*idleTerminationMinutes*/ '30',
      /*usePrivateDnsName*/ false,
      /*instanceCapStr*/ '#{slave['instance_cap']}',
      /*iamInstanceProfile*/ '',
      /*useEphemeralDevices*/ false,
      /*useDedicatedTenancy*/ false,
      /*launchTimeoutStr*/ '',
      /*associatePublicIp*/ false,
      /*customDeviceMapping*/ '',
      /*connectBySSHProcess*/ false,
      /*connectUsingPublicIp*/ false
    )
  EOF
end

jenkins_script 'configure_amazon_ec2_plugin' do
  command <<~EOF
    import jenkins.model.Jenkins
    import hudson.plugins.ec2.AmazonEC2Cloud
    import hudson.plugins.ec2.SlaveTemplate
    import com.amazonaws.services.ec2.model.InstanceType
    import hudson.plugins.ec2.UnixData
    import hudson.plugins.ec2.WindowsData
    import hudson.model.Node

    Jenkins instance = Jenkins.getInstance()

    cloudName = 'Amazon EC2'
    useInstanceProfileForCredentials = false
    credentialsId = 'AWS'
    region = '#{node['jenkins']['ec2_cloud']['region']}'
    privateKey = '''#{node['fidata']['jenkins']['private_key'].chomp}'''
    instanceCapStr = ''
    templates = [
      #{slave_templates.join(",\n")}
    ]
    AmazonEC2Cloud ec2Cloud = new AmazonEC2Cloud(
      cloudName,
      useInstanceProfileForCredentials,
      credentialsId,
      region,
      privateKey,
      instanceCapStr,
      templates
    )

    instance.clouds.clear()
    instance.clouds.add(ec2Cloud)

    instance.save()
  EOF
  action :execute
end

# Create admin user

jenkins_user 'admin' do
  id node['fidata']['chef']['username']
  full_name node['fidata']['chef']['full_name']
  email node['fidata']['chef']['email']
  password node['fidata']['chef']['jenkins']['password']
  public_keys [node['fidata']['chef']['public_key'].chomp]
  action :create
end

# Configure security

case node['jenkins']['master']['security']
when 'basic'
  jenkins_script 'setup_basic_security' do
    command <<~EOF
      import jenkins.model.Jenkins
      import hudson.security.SecurityRealm
      import hudson.security.HudsonPrivateSecurityRealm
      import hudson.security.AuthorizationStrategy
      import hudson.security.FullControlOnceLoggedInAuthorizationStrategy

      Jenkins instance = Jenkins.getInstance()

      // Authentication
      SecurityRealm securityRealm = new HudsonPrivateSecurityRealm(false)

      instance.setSecurityRealm(securityRealm)

      // Authorization
      AuthorizationStrategy authorizationStrategy = new FullControlOnceLoggedInAuthorizationStrategy()

      instance.setAuthorizationStrategy(authorizationStrategy)

      instance.save()
    EOF
    action :execute
  end
when 'github'
  jenkins_script 'setup_github_security' do
    command <<~EOF
      import jenkins.model.Jenkins
      import hudson.security.SecurityRealm
      import org.jenkinsci.plugins.GithubSecurityRealm
      import hudson.security.AuthorizationStrategy
      import org.jenkinsci.plugins.GithubAuthorizationStrategy

      Jenkins instance = Jenkins.getInstance()

      // Authentication
      SecurityRealm securityRealm = new GithubSecurityRealm(
        'https://github.com',
        'https://api.github.com',
        '#{node['jenkins']['github_oauth']['client_id']}',
        '#{node['jenkins']['github_oauth']['client_secret']}',
        'read:org,user:email'
      )

      instance.setSecurityRealm(securityRealm)

      // Authorization
      String adminUserNames = '#{node['fidata']['chef']['username']}'
      String organizationNames = 'FIDATA'
      boolean useRepositoryPermissions = true
      boolean authenticatedUserReadPermission = true
      boolean authenticatedUserCreateJobPermission = true
      boolean allowGithubWebHookPermission = true
      boolean allowCcTrayPermission = false
      boolean allowAnonymousReadPermission = false
      boolean allowAnonymousJobStatusPermission = true

      AuthorizationStrategy authorizationStrategy = new GithubAuthorizationStrategy(
        adminUserNames,
        authenticatedUserReadPermission,
        useRepositoryPermissions,
        authenticatedUserCreateJobPermission,
        organizationNames,
        allowGithubWebHookPermission,
        allowCcTrayPermission,
        allowAnonymousReadPermission,
        allowAnonymousJobStatusPermission
      )

      instance.setAuthorizationStrategy(authorizationStrategy)

      instance.save()
    EOF
    action :execute
  end
end

# Disable CLI over Remoting

template 'disable_jenkins_cli_over_remoting' do
  source 'jenkins.CLI.xml.erb'
  variables(
    enabled: false,
  )
  path "#{node['jenkins']['master']['home']}/jenkins.CLI.xml"
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode '0644'
  action :create
end

# Clean up after bootstrapping security

ruby_block 'bootstrap_security_cleanup' do # ~FC014
  block do
    run_context.resource_collection.find(template: 'bootstrap-security.groovy').run_action :delete
    run_context.resource_collection.find(directory: 'init_scripts_dir').run_action :delete
    run_context.resource_collection.find(service: 'jenkins').run_action :restart
  end
  action :run
end

# Turn on scm-sync-configuration plugin

if node['jenkins']['master']['scm_sync_configuration']['enabled']
  ruby_block 'enable_scm_sync_configuration_plugin' do
    block do
      run_context.resource_collection.find(file: scm_sync_configuration_disabled_file).run_action :delete
    end
  end
end
