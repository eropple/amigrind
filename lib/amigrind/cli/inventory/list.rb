module Amigrind
  module CLI
    INVENTORY.add_command(
      Cri::Command.define do
        name          'list'
        description   'lists Amigrind AMIs from the specified region'

        run do |opts, args, _|
          raise 'TODO; look in the AWS console for now'
        end
      end
    )
  end
end
