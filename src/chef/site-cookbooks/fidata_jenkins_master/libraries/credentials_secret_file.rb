#
# Cookbook:: jenkins
# HWRP:: jenkins_secret_file_credentials
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
  class Resource::JenkinsSecretFileCredentials < Resource::JenkinsCredentials
    resource_name :jenkins_secret_file_credentials

    # Chef attributes
    identity_attr :description

    # Attributes
    attribute :description,
              kind_of: String,
              name_attribute: true
    attribute :filename,
              kind_of: String,
              required: true
    attribute :content,
              kind_of: String,
              required: true,
              sensitive: true
  end
end

class Chef
  class Provider::JenkinsSecretFileCredentials < Provider::JenkinsCredentials
    use_inline_resources
    provides :jenkins_secret_file_credentials

    def load_current_resource
      @current_resource ||= Resource::JenkinsSecretFileCredentials.new(new_resource.name)

      super

      if current_credentials
        @current_resource.filename(current_credentials[:filename])
        @current_resource.content(current_credentials[:content])
      end

      @current_credentials
    end

    private

    #
    # @see Chef::Resource::JenkinsCredentials#credentials_groovy
    # @see https://github.com/jenkinsci/plain-credentials-plugin/blob/master/src/main/java/org/jenkinsci/plugins/plaincredentials/impl/FileCredentialsImpl.java
    #
    def credentials_groovy
      <<-EOH.gsub(/ ^{8}/, '')
        import com.cloudbees.plugins.credentials.*
        import org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl
        import org.apache.commons.fileupload.FileItem

        credentials = new FileCredentialsImpl(
          CredentialsScope.SYSTEM,
          #{convert_to_groovy(new_resource.id)},
          #{convert_to_groovy(new_resource.description)},
          [getName: { '' }] as FileItem,
          #{convert_to_groovy(new_resource.filename)},
          #{convert_to_groovy(new_resource.content)}
        )
      EOH
    end

    #
    # @see Chef::Resource::JenkinsCredentials#fetch_credentials_groovy
    #
    def fetch_existing_credentials_groovy(groovy_variable_name)
      <<-EOH.gsub(/ ^{8}/, '')
        #{credentials_for_id_groovy_extended(new_resource.id, groovy_variable_name, 'org.jenkinsci.plugins.plaincredentials', 'FileCredentials')}
      EOH
    end

    #
    # @see Chef::Resource::JenkinsCredentials#resource_attributes_groovy
    #
    def resource_attributes_groovy(groovy_variable_name)
      <<-EOH.gsub(/ ^{8}/, '')
        #{groovy_variable_name} = [
          id:credentials.id,
          description:credentials.description,
          filename:credentials.fileName,
          content:credentials.content
        ]
      EOH
    end

    #
    # @see Chef::Resource::JenkinsCredentials#attribute_to_property_map
    #
    def attribute_to_property_map
      { content: 'credentials.content.text' }
    end

    #
    # @see Chef::Resource::JenkinsCredentials#correct_config?
    #
    def correct_config?
      wanted_credentials = {
        description: new_resource.description,
        filename: new_resource.filename,
        content: new_resource.content,
      }

      attribute_to_property_map.keys.each do |key|
        wanted_credentials[key] = new_resource.send(key)
      end

      # Don't compare the ID as it is generated
      current_credentials.dup.tap { |c| c.delete(:id) } == convert_blank_values_to_nil(wanted_credentials)
    end
  end
end
