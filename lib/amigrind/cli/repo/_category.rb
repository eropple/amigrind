module Amigrind
  module CLI
    REPO = Cri::Command.define do
      name        'repo'
      description 'commands related to managing and creating Amigrind repos'

      run do |_, _, cmd|
        puts cmd.help
        exit 0
      end
    end

    ROOT.add_command(REPO)
  end
end
