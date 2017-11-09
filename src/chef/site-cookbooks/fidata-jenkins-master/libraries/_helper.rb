module Jenkins
  module Helper
    #
    # A Groovy snippet that will set the requested local Groovy variable
    # to an instance of the credentials represented by `username`.
    # Returns the Groovy `null` if no credentials are found.
    #
    # @param [String] username
    # @param [String] groovy_variable_name
    # @return [String]
    #
    def credentials_for_id_groovy_extended(id, groovy_variable_name, package, type)
      <<-EOH.gsub(/ ^{8}/, '')
        import jenkins.model.*
        import com.cloudbees.plugins.credentials.*
        import com.cloudbees.plugins.credentials.impl.*
        import com.cloudbees.plugins.credentials.common.*
        import com.cloudbees.plugins.credentials.domains.*
        import #{package}.#{type}

        id_matcher = CredentialsMatchers.withId("#{id}")
        available_credentials =
          CredentialsProvider.lookupCredentials(
            #{type}.class,
            Jenkins.getInstance(),
            hudson.security.ACL.SYSTEM,
            new SchemeRequirement("ssh")
          )

        #{groovy_variable_name} =
          CredentialsMatchers.firstOrNull(
            available_credentials,
            id_matcher
          )
      EOH
    end
  end
end
