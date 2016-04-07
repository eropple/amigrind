module Amigrind
  module Blueprints
    class Provisioner
      include Virtus.model(constructor: false, mass_assignment: false)

      attribute :name, String
      attribute :weight, Fixnum

      def racker_name
        "#{name}-#{weight}-#{self.class.name.demodulize}"
      end

      def to_racker_hash
        raise "#{self.class.name}#to_racker_hash must be implemented."
      end
    end
  end
end

Dir["#{__dir__}/provisioners/**.rb"].each { |f| require_relative f }
