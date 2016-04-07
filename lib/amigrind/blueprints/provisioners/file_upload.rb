module Amigrind
  module Blueprints
    module Provisioners
      class FileUpload < Amigrind::Blueprints::Provisioner
        attribute :source, String
        attribute :destination, String
        attribute :direction_method, String

        def direction=(dir)
          case dir
          when :download, :upload
            @direction_method = dir.to_s
          else
            raise "unrecognized 'direction': #{dir}"
          end
        end

        def to_racker_hash
          {
            type: 'file',
            source: @source,
            destination: @destination,
            direction: @direction_method
          }.delete_if { |_, v| v.nil? }
        end
      end
    end
  end
end
