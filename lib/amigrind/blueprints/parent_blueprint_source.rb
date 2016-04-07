module Amigrind
  module Blueprints
    class ParentBlueprintSource
      include Virtus.model(constructor: false, mass_assignment: false)

      attribute :name, String
      attribute :channel, Symbol
    end
  end
end
