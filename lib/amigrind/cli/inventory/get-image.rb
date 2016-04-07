module Amigrind
  module CLI
    INVENTORY.add_command(
      Cri::Command.define do
        name          'get-image'
        description   'gets an image from an Amigrind channel'

        CLI.output_format_options(self)

        CLI.repo_options(self)
        CLI.environment_options(self)

        option nil, :'steps-back',
               "number of steps back from the head of the channel to request (default: 0)",
               argument: :required

        run do |opts, args, _|
          CLI.with_repo_and_env(opts) do |repo, env|
            raise "usage: amigrind inventory get-image BLUEPRINT_NAME CHANNEL"\
              unless args.size == 2

            blueprint_name = args[0]
            channel_name = args[1].to_sym

            steps_back = (opts[:'steps-back'] || 0).to_i

            image = repo.get_image_by_channel(env, blueprint_name, channel_name, steps_back)
            puts JSON.pretty_generate(name: image.name, ami: image.id)
          end
        end
      end
    )
  end
end
