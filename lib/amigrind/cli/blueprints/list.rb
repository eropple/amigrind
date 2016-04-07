module Amigrind
  module CLI
    BLUEPRINTS.add_command(
      Cri::Command.define do
        name          'list'
        description   'lists Amigrind blueprints in the Amigrind repo'

        CLI.repo_options(self)

        CLI.output_format_options(self)

        run do |opts, _, cmd|
          Amigrind::Repo.with_repo(path:  opts[:'repo-path']) do |repo|
            # TODO: provide more information
            JSON.pretty_generate(repo.blueprint_names.map { |n| { name: n } })
          end
        end
      end
    )
  end
end
