module Amigrind
  module CLI
    ENVIRONMENTS = Cri::Command.define do
      name        'environments'
      description 'commands related to Amigrind environments in your Amigrind repo'

      run do |_, _, cmd|
        puts cmd.help
        exit 0
      end
    end

    ROOT.add_command(ENVIRONMENTS)
  end
end
