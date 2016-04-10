module Amigrind
  module Blueprints
    class Evaluator
      include Amigrind::Core::Logging::Mixin
      include Amigrind::Blueprints::Provisioners

      attr_reader :blueprint

      def initialize(filename, environment = nil)
        @blueprint = Blueprint.new
        @blueprint.name = File.basename(filename, ".rb")

        regex = Amigrind::Core::BLUEPRINT_NAME_REGEX
        raise "blueprint name (#{@blueprint.name}) must match #{regex.source}" \
          unless regex.match(@blueprint.name)

        @properties =
          if environment.nil?
            debug_log "no environment found to use with blueprint"
            {}
          else
            debug_log "using environment '#{environment.name}' with blueprint"
            environment.properties.merge(environment_name: environment.name)
          end

        unless environment.nil?
          @blueprint.aws.vpc_id = environment.aws.vpc
          @blueprint.aws.subnet_ids = environment.aws.subnets

          @blueprint.aws.region = environment.aws.region
          @blueprint.aws.copy_regions = environment.aws.copy_regions
          @blueprint.aws.ssh_keypair_name = environment.aws.ssh_keypair_name
        end

        instance_eval(IO.read(filename), File.expand_path(filename), 0)
      end

      def self.evaluate(filename, environment = nil)
        Evaluator.new(filename, environment).blueprint
      end

      def properties
        @properties
      end

      private

      def build_channel(b)
        raise "'build_channel' must be a String or Symbol." \
          unless b.is_a?(String) || b.is_a?(Symbol)

        @blueprint.build_channel = b
      end

      def description(d)
        raise "'description' must be a String." unless d.is_a?(String)
        @blueprint.description = d
      end

      def parent_blueprint(p)
        raise "'parent_blueprint' must be a String." unless p.is_a?(String)
        @blueprint.source = p
      end

      def source(type, &block)
        case type
        when :ami
          BaseAMIEvaluator.new(@blueprint, self, &block)
        when :parent
          ParentBlueprintEvaluator.new(@blueprint, self, &block)
        else
          raise "Invalid source type: #{type} (must be :ami, :parent)"
        end
      end

      def aws(&block)
        AWSConfigEvaluator.new(@blueprint, self, &block)
      end

      def provisioner(name, provisioner_class, weight: nil, &block)
        highest_provisioner = @blueprint.provisioners.max_by(&:weight)
        weight ||= (highest_provisioner.nil? ? 0 : highest_provisioner.weight) + 1

        raise "'name' must be a String or Symbol." \
          unless name.is_a?(String) || name.is_a?(Symbol)
        raise "'provisioner_class' must inherit from Amigrind::Blueprints::Provisioner" \
          unless provisioner_class.ancestors.include?(Amigrind::Blueprints::Provisioner)
        raise "'weight' must be a Fixnum." unless weight.is_a?(Fixnum)

        @blueprint.provisioners <<
          ProvisionerEvaluator.new(name, self, weight, provisioner_class, &block).provisioner
      end

      class BaseAMIEvaluator
        def initialize(bp, evaluator, &block)
          @bp = bp
          @bp.source = Amigrind::Blueprints::BaseAMISource.new

          @evaluator = evaluator

          instance_eval(&block)
        end

        private

        def properties
          @evaluator.properties
        end

        def family(f)
          raise "'family' must implement #to_sym." unless f.respond_to?(:to_sym)

          @bp.source.family = f.to_sym.to_s.strip.to_sym
        end

        def version(v)
          raise "'version' must be a String." unless v.is_a?(String)

          @bp.source.version = v.strip
        end

        def id(region, image_id)
          regex = Amigrind::Core::AMI_REGEX

          raise "'region' must be stringable." unless region.respond_to?(:to_s)
          raise "'image_id' must be in AMI format (/#{regex.source}/)" \
            unless regex.match(image_id)

          @bp.source.ids[region.to_s.strip] = image_id
        end

        def ids(ami_ids)
          raise "'ami_ids' must be a Hash-alike." unless ami_ids.respond_to?(:each_pair)
          ami_ids.each_pair { |region, image_id| id(region, image_id) }
        end
      end

      class ParentBlueprintEvaluator
        def initialize(bp, evaluator, &block)
          @bp = bp
          @bp.source = Amigrind::Blueprints::ParentBlueprintSource.new

          @evaluator = evaluator

          instance_eval(&block)
        end

        private

        def properties
          @evaluator.properties
        end

        def name(n)
          raise "'name' must be a String." unless n.is_a?(String)

          @bp.source.name = n
        end

        def channel(c)
          raise "'channel' must implement #to_sym." unless c.respond_to?(:to_sym)

          @bp.source.channel = c
        end
      end

      class AWSConfigEvaluator
        def initialize(bp, evaluator, &block)
          @bp = bp

          @evaluator = evaluator

          instance_eval(&block)
        end

        private

        def properties
          @evaluator.properties
        end

        def run_tag(key, value)
          raise "'key' must be a String." unless key.is_a?(String)
          raise "'value' must be stringable." unless value.respond_to?(:to_s)

          @bp.aws.run_tags[key] = value.to_s
        end

        def run_tags(tags)
          raise "'tags' must be a Hash." unless tags.respond_to?(:each_pair)
          tags.each_pair { |key, value| run_tag(key, value) }
        end

        def run_volume_tag(key, value)
          raise "'key' must be a String." unless key.is_a?(String)
          raise "'value' must be stringable." unless value.respond_to?(:to_s)

          @bp.aws.run_volume_tags[key] = value.to_s
        end

        def run_volume_tags(tags)
          raise "'tags' must be a Hash." unless tags.respond_to?(:each_pair)
          tags.each_pair { |key, value| run_volume_tag(key, value) }
        end

        def vpc(vpc_id)
          regex = Amigrind::Core::VPC_REGEX
          raise "'vpc_id' must be a resource (#{regex.source})" unless regex.match(vpc_id)

          @bp.aws.vpc_id = vpc_id
        end

        def subnet(subnet_id)
          regex = Amigrind::Core::SUBNET_REGEX
          raise "'subnet_id' must be a resource (#{regex.source})" unless regex.match(subnet_id)

          @bp.aws.subnet_ids << subnet_id
        end

        def security_group(sg_id)
          regex = Amigrind::Core::SG_REGEX
          raise "'sg_id' must be a resource (#{regex.source})." unless regex.match(sg_id)

          @bp.aws.security_group_ids << sg_id
        end

        def custom(key, value)
          raise "custom 'key' must be a Symbol." unless key.is_a?(Symbol)
          raise "custom 'value' must be non-nil." if value.nil?

          @bp.aws.custom[key] = value
        end

        def method_missing(m, *args)
          @bp.aws.send(:"#{m}=", args[0])
        end
      end
    end

    class ProvisionerEvaluator
      attr_reader :provisioner

      def initialize(name, evaluator, weight, provisioner_class, &block)
        @provisioner = provisioner_class.new
        @provisioner.name = name.to_s
        @provisioner.weight = weight

        @evaluator = evaluator

        instance_eval(&block)
      end

      def method_missing(m, *args)
        eq_msg = :"#{m}="

        if @provisioner.respond_to?(eq_msg)
          @provisioner.send(eq_msg, args[0])
        else
          @provisioner.send(m, *args)
        end
      end

      private

      def properties
        @evaluator.properties
      end
    end
  end
end
