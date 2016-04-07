module Amigrind
  module Build
    class Rackerizer
      include Amigrind::Core::Logging::Mixin
      include Virtus.model(constructor: false, mass_assignment: false)

      attribute :amigrind_client, Amigrind::Core::Client
      attribute :blueprint, Amigrind::Blueprints::Blueprint
      attribute :repo, Amigrind::Repo

      def initialize(amigrind_client, blueprint, repo)
        @amigrind_client = amigrind_client
        @blueprint = blueprint
        @repo = repo
      end

      def rackerize
        t = Racker::Template.new

        do_builder(t)
        do_provisioners(t)

        JSON.pretty_generate(t.to_packer)
      end

      private

      def do_builder(t)
        latest_build =
          @amigrind_client.get_image_by_channel(name: @blueprint.name, channel: :latest)
        build_id =
          if latest_build.nil?
            1
          else
            latest_build.tags.find { |t| t.key == Amigrind::Core::AMIGRIND_ID_TAG }.value.to_i + 1
          end

        source_ami =
          if @blueprint.source.is_a?(Amigrind::Blueprints::BaseAMISource)
            ami_id = @blueprint.source.ids[@blueprint.aws.region]

            raise "source AMI was not provided for region #{@blueprint.aws.region}." if ami_id.nil?
            ami_id
          elsif @blueprint.source.is_a?(Amigrind::Blueprints::ParentBlueprintSource)
            parent_name = @blueprint.source.name
            parent_channel = @blueprint.source.channel

            parent_image =
              @amigrind_client.get_image_by_channel(name: parent_name,
                                                    channel: parent_channel)

            raise "parent image (#{parent_name} #{parent_channel}) not found." if parent_image.nil?

            parent_image.id
          else
            raise "blueprint source is unrecognized (#{@blueprint.source.class})"
          end

        raise "source_ami is nil; check to make sure!" if source_ami.nil?

        amigrind_tags = {
          Amigrind::Core::AMIGRIND_NAME_TAG => @blueprint.name,
          Amigrind::Core::AMIGRIND_ID_TAG => build_id
        }.delete_if { |_, v| v.nil? }

        unless @blueprint.build_channel.nil?
          channel_tag =
            Amigrind::Core::AMIGRIND_CHANNEL_TAG % { channel_name: @blueprint.build_channel }
          amigrind_tags[channel_tag] = 1
        end

        unless parent_image.nil? # we're in a parented image
          amigrind_tags[Amigrind::Core::AMIGRIND_PARENT_NAME_TAG] = @blueprint.source.name
          amigrind_tags[Amigrind::Core::AMIGRIND_PARENT_ID_TAG] =
            parent_image.tags.find { |t| t.key == Amigrind::Core::AMIGRIND_ID_TAG }.value
        end

        # Note that we do not pull in credentials here! That would fail hilariously and
        # with much gnashing of teeth if we're on an instance with IAM credentials.
        # Instead, when we execute Packer on this script, we pass along environment
        # variables containing AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY or AWS_PROFILE,
        # like a boss or boss-shaped object.
        #
        # This also lets us avoid having sensitive information in the Packer file that
        # we might, say, print to stdout.
        builder = {
          type: 'amazon-ebs',
          ami_name: "#{@blueprint.name}-#{build_id.to_s.rjust(6, '0')}",
          source_ami: source_ami,

          instance_type: @blueprint.aws.instance_type,
          ssh_username: @blueprint.aws.ssh_username,

          region: @blueprint.aws.region,
          ami_regions: @blueprint.aws.copy_regions,

          ami_description: @blueprint.description,

          launch_block_device_mappings: @blueprint.aws.launch_block_device_mappings,
          ami_block_device_mappings: @blueprint.aws.ami_block_device_mappings,

          associate_public_ip_address: @blueprint.aws.associate_public_ip_address,
          ebs_optimized: @blueprint.aws.ebs_optimized,
          enhanced_networking: @blueprint.aws.enhanced_networking,
          force_deregister: false, # no, this will not be allowed
          iam_instance_profile: @blueprint.aws.iam_instance_profile,
          run_tags: @blueprint.aws.run_tags,
          run_volume_tags: @blueprint.aws.run_volume_tags,
          security_group_ids: @blueprint.aws.security_group_ids,
          ssh_keypair_name: @blueprint.aws.ssh_keypair_name,
          ssh_private_ip: @blueprint.aws.ssh_private_ip,
          subnet_id: @blueprint.aws.subnet_ids.sample, # randomly select from allowed subnets
          user_data: @blueprint.aws.user_data,
          vpc_id: @blueprint.aws.vpc_id,

          tags: amigrind_tags
        }
        builder[:windows_password_timeout] = "#{@blueprint.aws.windows_password_timeout}s" \
          unless @blueprint.aws.windows_password_timeout.nil?

        t.builders['amigrind'] = builder.delete_if { |_, v| [ nil, [], {} ].include?(v) }.deep_stringify_keys
      end

      def do_provisioners(t)
        @blueprint.provisioners.each do |provisioner|
          t.provisioners[provisioner.weight.to_i] = {}
          rh = provisioner.to_racker_hash
          rh.delete_if { |k, v| v.nil? || v == [] }
          t.provisioners[provisioner.weight.to_i][provisioner.racker_name] = rh
        end
      end
    end
  end
end
