module Amigrind
  module CLI
    ENVIRONMENTS.add_command(
      Cri::Command.define do
        name          'show'
        description   'displays a single Amigrind environment'

        CLI.repo_options(self)

        CLI.output_format_options(self)

        run do |opts, args, cmd|
          Amigrind::Repo.with_repo(path:  opts[:'repo-path']) do |repo|
            repo.with_environment(args[0]) do |env|
              YAML.dump(env)
            end
          end
        end
      end
    )
  end
end
