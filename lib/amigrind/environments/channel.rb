module Amigrind
  module Environments
    class Channel
      include Virtus.model

      attribute :name, String
    end
  end
end
