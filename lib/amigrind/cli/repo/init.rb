require 'amigrind/repo'

module Amigrind
  module CLI
    REPO.add_command(
      Cri::Command.define do
        name          'init'
        description   'initializes new repo'

        run do |_, args, _|
          path = args.first

          raise "A path is required to initialize a repo." if path.nil?

          path = File.expand_path(path)

          raise "Cannot initialize a repo into an existing path." if Dir.exist?(path)

          Amigrind::Repo.init(path: path)
        end
      end
    )
  end
end
