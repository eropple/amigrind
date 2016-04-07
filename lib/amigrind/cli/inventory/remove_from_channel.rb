module Amigrind
  module CLI
    INVENTORY.add_command(
      Cri::Command.define do
        name          'remove-from-channel'
        description   'remove a given AMI from an Amigrind channel'

        CLI.output_format_options(self)

        CLI.repo_options(self)
        CLI.environment_options(self)

        run do |opts, args, _|
          CLI.with_repo_and_env(opts) do |repo, env|
            raise "usage: amigrind inventory remove-from-channel BLUEPRINT_NAME AMI_NUMBER CHANNEL_NAME"\
              unless args.size == 3

            blueprint_name = args[0]
            ami_number = args[1].to_i
            channel_name = args[2].to_sym

            repo.remove_from_channel(env, blueprint_name, ami_number, channel_name)
          end
        end
      end
    )
  end
end
