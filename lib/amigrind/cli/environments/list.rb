module Amigrind
  module CLI
    ENVIRONMENTS.add_command(
      Cri::Command.define do
        name          'list'
        description   'lists Amigrind environments in the Amigrind repo'

        CLI.repo_options(self)

        CLI.output_format_options(self)

        flag nil, :terse, "only print environment names"

        run do |opts, _, cmd|
          Amigrind::Repo.with_repo(path: opts[:'repo-path']) do |repo|
            # TODO: provide more information
            JSON.pretty_generate(repo.environment_names.map { |n| { name: n } })
          end
        end
      end
    )
  end
end
