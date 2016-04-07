module Amigrind
  module CLI
    BUILD.add_command(
      Cri::Command.define do
        name          'print-packer'
        description   'evaluates an Amigrind blueprint and prints Packer JSON'

        CLI.output_format_options(self)

        CLI.repo_options(self)
        CLI.environment_options(self)
        CLI.blueprint_options(self)

        run do |opts, args, _|
          CLI.with_repo_and_env(opts) do |repo, env|
            bp = repo.evaluate_blueprint(args[0], env)
            credentials = Amigrind::Config.aws_credentials(env)

            builder = Amigrind::Builder.new(credentials, bp, repo)
            template = builder.rackerize

            puts template
          end
        end
      end
    )
  end
end
