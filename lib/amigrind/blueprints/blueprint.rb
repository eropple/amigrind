require 'amigrind/blueprints/provisioner'

module Amigrind
  module Blueprints
    class Blueprint
      include Virtus.model(constructor: false, mass_assignment: false)

      attribute :name, String
      attribute :build_channel, Symbol
      attribute :description, String, default: ''
      attr_accessor :source
      attribute :aws, Amigrind::Blueprints::AWSConfig

      attribute :provisioners, Array[Amigrind::Blueprints::Provisioner], default: []

      def initialize
        @aws = AWSConfig.new
        @provisioners = []
      end
    end
  end
end
