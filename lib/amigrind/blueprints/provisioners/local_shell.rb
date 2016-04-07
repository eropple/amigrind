module Amigrind
  module Blueprints
    module Provisioners
      class LocalShell < Amigrind::Blueprints::Provisioner
        attribute :inline, Array[String]

        def command=(cmd)
          raise "'command' must be a String or an array of String." \
            unless cmd.is_a?(String) ||
                   (cmd.respond_to?(:all?) && cmd.all? { |l| l.is_a?(String) })

          if cmd.is_a?(String)
            @inline = cmd.split("\n")
          else
            @inline = cmd
          end
        end

        def to_racker_hash
          {
            type: 'shell-local',
            command: @inline.join("\n")
          }
        end
      end
    end
  end
end
