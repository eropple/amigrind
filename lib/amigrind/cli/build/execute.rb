module Amigrind
  module CLI
    BUILD.add_command(
      Cri::Command.define do
        name          'execute'
        description   'evaluates an Amigrind blueprint and runs it through Packer'

        CLI.output_format_options(self)

        CLI.repo_options(self)
        CLI.environment_options(self)
        CLI.blueprint_options(self)

        flag nil, :'show-spools', 'if set, includes Packer output in stdout output.'

        run do |opts, args, _|
          CLI.with_repo_and_env(opts) do |repo, env|
            bp = repo.evaluate_blueprint(args[0], env)
            credentials = Amigrind::Config.aws_credentials(env)

            builder = Amigrind::Builder.new(credentials, bp, repo)

            retval = builder.build
            retval.delete(:spools) unless opts[:'show-spools']

            puts JSON.pretty_generate(retval)
          end
        end
      end
    )
  end
end
