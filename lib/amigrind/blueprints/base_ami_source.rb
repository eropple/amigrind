module Amigrind
  module Blueprints
    class BaseAMISource
      include Virtus.model(constructor: false, mass_assignment: false)

      attribute :family, Symbol
      attribute :version, String
      attribute :ids, Hash[String => String]

      def initialize
        @ids = {}
      end
    end
  end
end
