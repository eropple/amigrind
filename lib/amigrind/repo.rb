module Amigrind
  class Repo
    include Amigrind::Core::Logging::Mixin

    attr_reader :path

    def initialize(path)
      @path = File.expand_path path

      raise "'path' (#{path}) is not a directory." unless Dir.exist?(path)
      raise "'path' is not an Amigrind root (lacks .amigrind_root file)." \
        unless File.exist?(File.join(path, '.amigrind_root'))

      info_log "using Amigrind path: #{path}"
    end

    def environments_path
      File.join(path, 'environments')
    end

    def blueprints_path
      File.join(path, 'blueprints')
    end

    # TODO: Ruby DSL environments
    def environment_names
      yaml_environments =
        Dir[File.join(environments_path, '*.yaml')] \
          .map { |f| File.basename(f, '.yaml').to_s.strip.downcase }

      rb_environments =
        [].map { |f| File.basename(f, '.rb').to_s.strip.downcase }

      duplicate_environments = yaml_environments & rb_environments
      duplicate_environments.each do |dup_env_name|
        warn_log "environment '#{dup_env_name}' found in both YAML and Ruby; skipping."
      end

      (yaml_environments + rb_environments - duplicate_environments).sort
    end

    # TODO: cache environments (but make configurable)
    def environment(name)
      yaml_path = yaml_path_if_exists(name)
      rb_path = rb_path_if_exists(name)

      raise "found multiple env files for same env #{name}." if !yaml_path.nil? && !rb_path.nil?
      raise "TODO: implement Ruby environments." unless rb_path.nil?

      env = Environments::Environment.load_yaml_file(yaml_path) unless yaml_path.nil?

      raise "no env found for '#{name}'." if env.nil?

      IceNine.deep_freeze(env)
      env
    end

    def with_environment(environment_name, &block)
      block.call(environment(environment_name))
    end

    def blueprint_names
      Dir[File.join(blueprints_path, "*.rb")].map { |f| File.basename(f, ".rb") }
    end

    # TODO: cache blueprint/environment tuples (but make configurable)
    def evaluate_blueprint(blueprint_name, env)
      raise "'env' must be a String or an Environment." \
        unless env.is_a?(String) || env.is_a?(Environments::Environment)

      if env.is_a?(String)
        env = environment(env)
      end

      ev = Amigrind::Blueprints::Evaluator.new(File.join(blueprints_path,
                                                         "#{blueprint_name}.rb"),
                                               env)

      ev.blueprint
    end

    # TODO: refactor these client-y things.
    def add_to_channel(env, blueprint_name, id, channel)
      raise "'env' must be a String or an Environment." \
        unless env.is_a?(String) || env.is_a?(Environments::Environment)
      raise "'blueprint_name' must be a String." unless blueprint_name.is_a?(String)
      raise "'id' must be a Fixnum." unless id.is_a?(Fixnum)
      raise "'channel' must be a String or Symbol." \
        unless channel.is_a?(String) || channel.is_a?(Symbol)

      if env.is_a?(String)
        env = environment(env)
      end

      raise "channel '#{channel}' does not exist in environment '#{env.name}'." \
        unless env.channels.key?(channel.to_s) || channel.to_sym == :latest

      credentials = Amigrind::Config.aws_credentials(env)

      amigrind_client = Amigrind::Core::Client.new(env.aws.region, credentials)
      ec2 = Aws::EC2::Client.new(region: env.aws.region, credentials: credentials)

      image = amigrind_client.get_image_by_id(name: blueprint_name, id: id)

      tag_key = Amigrind::Core::AMIGRIND_CHANNEL_TAG % { channel_name: channel }

      info_log "setting '#{tag_key}' on image #{image.id}..."
      ec2.create_tags(
        resources: [ image.id ],
        tags: [
          {
            key: tag_key,
            value: '1'
          }
        ]
      )
    end

    def remove_from_channel(env, blueprint_name, id, channel)
      raise "'env' must be a String or an Environment." \
        unless env.is_a?(String) || env.is_a?(Environments::Environment)
      raise "'blueprint_name' must be a String." unless blueprint_name.is_a?(String)
      raise "'id' must be a Fixnum." unless id.is_a?(Fixnum)
      raise "'channel' must be a String or Symbol." \
        unless channel.is_a?(String) || channel.is_a?(Symbol)

      if env.is_a?(String)
        env = environment(env)
      end

      raise "channel '#{channel}' does not exist in environment '#{env.name}'." \
        unless env.channels.key?(channel.to_s) || channel.to_sym == :latest

      credentials = Amigrind::Config.aws_credentials(env)

      amigrind_client = Amigrind::Core::Client.new(env.aws.region, credentials)
      ec2 = Aws::EC2::Client.new(region: env.aws.region, credentials: credentials)

      image = amigrind_client.get_image_by_id(name: blueprint_name, id: id)

      tag_key = Amigrind::Core::AMIGRIND_CHANNEL_TAG % { channel_name: channel }

      info_log "clearing '#{tag_key}' on image #{image.id}..."
      ec2.delete_tags(
        resources: [ image.id ],
        tags: [
          {
            key: tag_key,
            value: nil
          }
        ]
      )
    end

    def get_image_by_channel(env, blueprint_name, channel, steps_back = 0)
      raise "'env' must be a String or an Environment." \
        unless env.is_a?(String) || env.is_a?(Environments::Environment)
      raise "'blueprint_name' must be a String." unless blueprint_name.is_a?(String)
      raise "'channel' must be a String or Symbol." \
        unless channel.is_a?(String) || channel.is_a?(Symbol)

      if env.is_a?(String)
        env = environment(env)
      end

      raise "channel '#{channel}' does not exist in environment '#{env.name}'." \
        unless env.channels.key?(channel.to_s) || channel.to_sym == :latest

      credentials = Amigrind::Config.aws_credentials(env)
      amigrind_client = Amigrind::Core::Client.new(env.aws.region, credentials)

      amigrind_client.get_image_by_channel(name: blueprint_name, channel: channel, steps_back: steps_back)
    end

    class << self
      def init(path:)
        raise "TODO: implement"
      end

      def with_repo(path: nil, &block)
        path = path || ENV['AMIGRIND_PATH'] || Dir.pwd

        repo = Repo.new(path)

        Dir.chdir path do
          block.call(repo)
        end
      end
    end

    private

    def yaml_path_if_exists(name)
      matches = [
        "#{environments_path}/#{name}.yml",
        "#{environments_path}/#{name}.yaml",
        "#{environments_path}/#{name}.yml.erb",
        "#{environments_path}/#{name}.yaml.erb"
      ].select { |f| File.exist?(f) }

      case matches.size
      when 0
        nil
      when 1
        matches.first
      else
        raise "found multiple env files for same env #{name}."
      end
    end

    def rb_path_if_exists(name)
      path = "#{environments_path}/#{name}.rb"

      File.exist?(path) ? path : nil
    end
  end
end
