require 'amigrind'
require 'cri'

Dir["#{__dir__}/cli/**/*.rb"].sort.each { |f| require_relative f }

module Amigrind
  module CLI
    def self.run(args)
      ROOT.run(args)
    end
  end
end
