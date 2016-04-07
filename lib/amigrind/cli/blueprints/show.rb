module Amigrind
  module CLI
    BLUEPRINTS.add_command(
      Cri::Command.define do
        name          'show'
        description   'displays an evaluated Amigrind blueprint'

        CLI.output_format_options(self)

        CLI.repo_options(self)
        CLI.environment_options(self)

        run do |opts, args, cmd|
          Amigrind::Repo.with_repo(path:  opts[:'repo-path']) do |repo|
            bp = repo.evaluate_blueprint(args[0], opts[:environment])
            puts YAML.dump(bp)
          end
        end
      end
    )
  end
end
