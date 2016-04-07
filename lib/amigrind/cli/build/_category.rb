module Amigrind
  module CLI
    BUILD = Cri::Command.define do
      name        'build'
      description 'commands related to building AMIs for consumption'

      run do |_, _, cmd|
        puts cmd.help
        exit 0
      end
    end

    ROOT.add_command(BUILD)
  end
end
