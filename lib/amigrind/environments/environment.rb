module Amigrind
  module Environments
    class Environment
      extend Amigrind::Core::Logging::Mixin

      include Virtus.model(constructor: false, mass_assignment: false)

      class AWSConfig
        include Virtus.model

        attribute :region, String
        attribute :copy_regions, Array[String]
        attribute :vpc, String
        attribute :subnets, Array[String]
        attribute :ssh_keypair_name, String
      end

      attribute :name, String
      attribute :channels, Hash[String => Channel]
      attribute :aws, AWSConfig
      attr_reader :properties

      def initialize
        @aws = AWSConfig.new
        @channels = []
        @properties = {}
      end

      def self.from_yaml(name, yaml_input)
        yaml = YAML.load(yaml_input).deep_symbolize_keys

        yaml[:amigrind] ||= {}
        yaml[:aws] ||= {}
        yaml[:properties] ||= {}

        env = Environment.new
        env.name = name.to_s.strip.downcase

        env.aws = AWSConfig.new(yaml[:aws])

        env.properties.merge!(yaml[:properties])

        env.channels = (yaml[:amigrind][:channels] || []).map do |k, v|
          [ k.to_s, Channel.new(v.merge(name: k)) ]
        end.to_h

        # TODO: use these for validations
        valid_mappings = {
          'root' => env,
          'aws' => env.aws
        }

        env
      end

      def self.load_yaml_file(path)
        raise "'path' must be a String." unless path.is_a?(String)
        raise "'path' must be a file that exists." unless File.exist?(path)
        raise "'path' must end in .yml, .yaml, .yml.erb, or .yaml.erb." \
          unless path.end_with?('.yml', '.yaml', '.yml.erb', '.yaml.erb')

        Environment.from_yaml(File.basename(path, '.*'), Erubis::Eruby.new(File.read(path)).result)
      end
    end
  end
end
