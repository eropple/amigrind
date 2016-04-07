require 'settingslogic'
require 'os'

module Amigrind
  # Config values we care about:
  # `auto_profile` - boolean; if set
  class Config < Settingslogic
    extend Amigrind::Core::Logging::Mixin
    include Amigrind::Core::Logging::Mixin

    CREDENTIAL_TYPES = [ :default, :iam, :shared ].freeze

    cfg_dir =
      ENV['AMIGRIND_CONFIG_PATH'] || "#{Dir.home}/.amigrind"
    cfg_file = "#{cfg_dir}/config.yaml"

    unless Dir.exist?(cfg_dir)
      info_log "initializing config directory"
      FileUtils.mkdir_p(cfg_dir)
      if OS.posix?
        info_log "chmodding config directory"
        FileUtils.chmod 'g=-rwx', cfg_dir
        FileUtils.chmod 'o=-rwx', cfg_dir
      end
    end
    unless File.exist?(cfg_file)
      info_log "touching config file to create it"
      FileUtils.touch(cfg_file)
      if OS.posix?
        info_log "chmodding config file"
        FileUtils.chmod 'g=-rwx', cfg_file
        FileUtils.chmod 'o=-rwx', cfg_file
      end
    end

    source cfg_file

    def aws_credentials(environment = nil)
      # This is a minor disaster and should be refactored, but essentially boils down
      # to specifying a credentials_type and any related settings. If
      # `auto_profile_from_environment` is set, any time that an environment is
      # passed in, `auto_profile_prefix` will be prepended to the environment name
      # to generate the AWS profile name. This allows one to, for example, have
      # a 'foocorp_production' profile that will be automatically used when working
      # with the 'production' environment.
      aws = Config['aws'] || {}

      credential_type = (aws['credentials_type'] || :default).to_sym
      auto_profile_from_environment = !!aws['auto_profile_from_environment']
      auto_profile_prefix = aws['auto_profile_prefix'] || ''
      profile_name = aws['profile_name']

      debug_log "credentials_type: #{credential_type}"

      raise "setting error: can only use profile_name with credential_type = shared." \
        if credential_type != :shared && !profile_name.nil?

      raise "setting error: cannot use both profile_name and auto_profile_from_environment." \
        if !profile_name.nil? && auto_profile_from_environment

      case credential_type
      when :default
        debug_log 'Using default credentials.'
        nil
      when :shared
        if auto_profile_from_environment &&
            profile_name.nil? && !environment.nil?
          environment = environment.name \
            if (environment.is_a?(Amigrind::Environments::Environment))

          profile_name = "#{auto_profile_prefix}#{environment}"
          debug_log "auto_profile_from_environment enabled and environment " \
                    "passed; setting profile_name to '#{profile_name}'."
        end

        p = (profile_name || 'default').strip

        debug_log "Using profile '#{p}'."
        Aws::SharedCredentials.new(profile_name: p)
      when :iam
        debug_log 'Using IAM credentials.'
        Aws::InstanceProfileCredentials.new
      else
        raise "invalid credential type '#{credential_type}' " \
              "(allowed: #{CREDENTIAL_TYPES.join(', ')})"
      end
    end
  end
end