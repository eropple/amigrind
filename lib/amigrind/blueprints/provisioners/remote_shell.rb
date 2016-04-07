module Amigrind
  module Blueprints
    module Provisioners
      class RemoteShell < Amigrind::Blueprints::Provisioner
        attribute :inline, Array[String]
        attribute :scripts, Array[String]
        attribute :binary, Boolean
        attribute :env_vars, Hash[String => String]
        attribute :execute_command, String
        attribute :inline_shebang, String
        attribute :remote_path, String
        attribute :skip_clean, Boolean
        attribute :start_retry_timeout, ActiveSupport::Duration

        def run_as_root!
          @execute_command = "{{ .Vars }} sudo -E -S sh '{{ .Path }}'"
        end

        def command=(cmd)
          raise "'command' must be a String or an array of String." \
            unless cmd.is_a?(String) ||
                   (cmd.respond_to?(:all?) && cmd.all? { |l| l.is_a?(String) })

          @inline = cmd.is_a?(String) ? cmd.split("\n") : cmd
        end

        def environment_vars=(vars)
          raise "'vars' must be a Hash with Symbol or String keys and stringable values." \
            unless vars.all? { |k, v| (k.is_a?(Symbol) || k.is_a?(String)) && v.respond_to?(:to_s)}

          @env_vars =
            (@env_vars || {}).merge(vars.map { |k, v| [ k.to_s, v.to_s ] }.to_h)
        end

        def to_racker_hash
          # This trims leading whitespace off of heredoc commands, but leaves
          # them as inlines. They're easier to read when you have to look at the Packer
          # output when you do this.
          trim_count = @inline.map { |line| line[/\A */].size }.min
          lines = @inline.map { |line| line[trim_count..-1] }

          {
            type: 'shell',
            binary: @binary,
            inline: lines,
            scripts: @scripts,
            environment_vars: (@env_vars || {}).map { |k, v| "#{k}=#{v}" },
            execute_command: @execute_command,
            inline_shebang: @inline_shebang,
            start_retry_timeout:
              @start_retry_timeout.nil? ? nil : "#{@start_retry_timeout}s"
          }
        end
      end
    end
  end
end
