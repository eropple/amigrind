module Amigrind
  module CLI
    class << self
      def output_format_options(cmd)
        cmd.option  :f, :format,
                    'output format',
                    argument: :required
      end

      def repo_options(cmd)
        cmd.option  nil, :'repo-path',
                    'path to the Amigrind repo',
                    argument: :required
      end

      def environment_options(cmd)
        cmd.option  nil, :environment,
                    'name of the environment in the Amigrind repo',
                    argument: :required
      end

      def blueprint_options(cmd)
        cmd.option  nil, :blueprint,
                    'name of the blueprint in the Amigrind repo',
                    argument: :required
      end

      def channel_options(cmd)
        cmd.option  nil, :channel,
                    'channel to use, from the selected Amigrind environment',
                    argument: :required
      end

      def environment_name_parse(opts)
        opts[:environment] ||
          (Amigrind::Config['amigrind'] || {})['default_environment'] ||
          'default'
      end

      def with_repo_and_env(opts, &block)
        Amigrind::Repo.with_repo(path: opts[:'repo-path']) do |repo|
          env_name = CLI.environment_name_parse(opts)

          block.call(repo, repo.environment(env_name))
        end
      end
    end
  end
end
