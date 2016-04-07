module Amigrind
  module CLI
    BLUEPRINTS = Cri::Command.define do
      name        'blueprints'
      description 'commands related to Amigrind blueprints in your Amigrind repo'

      run do |_, _, cmd|
        puts cmd.help
        exit 0
      end
    end

    ROOT.add_command(BLUEPRINTS)
  end
end
