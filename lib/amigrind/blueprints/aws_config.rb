require 'amigrind/environments/channel'

module Amigrind
  module Blueprints
    class AWSConfig
      include Virtus.model(constructor: false, mass_assignment: false)

      class BlockDeviceMapping
      end

      attribute :instance_type, String
      # TODO: ssh_username is currently required for all builds, but should
      #       instead inherit from the parent blueprint if one exists. This
      #       is annoying and recursive right now, and a small pain point,
      #       so I've punted it.
      attribute :ssh_username, String

      attribute :region, String
      attribute :copy_regions, Array[String]
      attribute :associate_public_ip_address, Boolean
      attribute :ebs_optimized, Boolean
      attribute :enhanced_networking, Boolean
      attribute :iam_instance_profile, String
      attribute :ssh_keypair_name, String
      attribute :ssh_private_ip, Boolean
      attribute :user_data, String
      attribute :windows_password_timeout, ActiveSupport::Duration

      attribute :run_tags, Hash[String => String]
      attribute :run_volume_tags, Hash[String => String]
      attribute :security_group_ids, Array[String]

      attribute :vpc_id, String
      attribute :subnet_ids, Array[String]

      # TODO: object-ize the ami block device mappings
      attribute :ami_block_device_mappings, Array[BlockDeviceMapping]
      attribute :launch_block_device_mappings, Array[BlockDeviceMapping]

      attr_reader :custom

      def initialize
        @copy_regions = []

        @run_tags = {}
        @run_volume_tags = {}
        @security_group_ids = []

        @subnet_ids = []

        @ami_block_device_mappings = []
        @launch_block_device_mappings = []

        @custom = {}
      end
    end
  end
end
