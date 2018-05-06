#
# Cookbook:: jenkins
# HWRP:: jenkins_aws_credentials
#
# Author:: Basil Peace <grv87@yandex.ru>
#
# Copyright:: 2017, Basil Peace
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative '../../jenkins/libraries/credentials'
require_relative '_helper'

class Chef
  class Resource::JenkinsAwsCredentials < Resource::JenkinsCredentials
    resource_name :jenkins_aws_credentials

    # Chef attributes
    identity_attr :description

    # Attributes
    attribute :access_key,
              kind_of: String,
              required: true
    attribute :secret_key,
              kind_of: String,
              required: true
    attribute :description,
              kind_of: String,
              name_attribute: true
    attribute :iam_role_arn,
              kind_of: String
  end
end

class Chef
  class Provider::JenkinsAwsCredentials < Provider::JenkinsCredentials
    use_inline_resources
    provides :jenkins_aws_credentials

    def load_current_resource
      @current_resource ||= Resource::JenkinsAwsCredentials.new(new_resource.name)

      super

      if current_credentials
        @current_resource.access_key(current_credentials[:access_key])
        @current_resource.secret_key(current_credentials[:secret_key])
        @current_resource.iam_role_arn(current_credentials[:iam_role_arn])
      end

      @current_credentials
    end

    private

    #
    # @see Chef::Resource::JenkinsCredentials#credentials_groovy
    # @see https://github.com/jenkinsci/aws-credentials-plugin/blob/master/src/main/java/com/cloudbees/jenkins/plugins/awscredentials/AWSCredentialsImpl.java
    #
    def credentials_groovy
      <<-EOH.gsub(/ ^{8}/, '')
        import com.cloudbees.plugins.credentials.*
        import com.cloudbees.jenkins.plugins.awscredentials.*

        credentials = new AWSCredentialsImpl(
          CredentialsScope.SYSTEM,
          #{convert_to_groovy(new_resource.id)},
          #{convert_to_groovy(new_resource.access_key)},
          #{convert_to_groovy(new_resource.secret_key)},
          #{convert_to_groovy(new_resource.description)},
          #{convert_to_groovy(new_resource.iam_role_arn)},
          null
        )
      EOH
    end

    #
    # @see Chef::Resource::JenkinsCredentials#fetch_credentials_groovy
    #
    def fetch_existing_credentials_groovy(groovy_variable_name)
      <<-EOH.gsub(/ ^{8}/, '')
        #{credentials_for_id_groovy_extended(new_resource.id, groovy_variable_name, 'com.cloudbees.jenkins.plugins.awscredentials', 'AmazonWebServicesCredentials')}
      EOH
    end

    #
    # @see Chef::Resource::JenkinsCredentials#resource_attributes_groovy
    #
    def resource_attributes_groovy(groovy_variable_name)
      <<-EOH.gsub(/ ^{8}/, '')
        #{groovy_variable_name} = [
          id:credentials.id,
          access_key:credentials.accessKey,
          secret_key:credentials.secretKey,
          description:credentials.description,
          iam_role_arn:credentials.iamRoleArn,
        ]
      EOH
    end

    #
    # @see Chef::Resource::JenkinsCredentials#attribute_to_property_map
    #
    def attribute_to_property_map
      { secret_key: 'credentials.secretKey.plainText' }
    end

    #
    # @see Chef::Resource::JenkinsCredentials#correct_config?
    #
    def correct_config?
      wanted_credentials = {
        access_key: new_resource.access_key,
        secret_key: new_resource.secret_key,
        description: new_resource.description,
        iam_role_arn: new_resource.iam_role_arn,
      }

      attribute_to_property_map.keys.each do |key|
        wanted_credentials[key] = new_resource.send(key)
      end

      # Don't compare the ID as it is generated
      current_credentials.dup.tap { |c| c.delete(:id) } == convert_blank_values_to_nil(wanted_credentials)
    end
  end
end
