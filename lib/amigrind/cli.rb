require 'amigrind'
require 'cri'

Dir["#{__dir__}/cli/**/*.rb"].each { |f| require_relative f }

module Amigrind
  module CLI
    def self.run(args)
      ROOT.run(args)
    end
  end
end
