module Amigrind
  module CLI
    INVENTORY = Cri::Command.define do
      name        'inventory'
      description 'commands related to the current Amigrind AMI inventory'

      run do |_, _, cmd|
        puts cmd.help
        exit 0
      end
    end

    ROOT.add_command(INVENTORY)
  end
end
