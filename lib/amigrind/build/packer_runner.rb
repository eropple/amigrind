module Amigrind
  module Build
    class PackerRunner
      include Virtus.model
      include Amigrind::Core::Logging::Mixin

      attribute :template, Hash
      attribute :amigrind_client, Amigrind::Core::Client
      attribute :blueprint, Amigrind::Blueprints::Blueprint
      attribute :repo, Amigrind::Repo

      def initialize(template, amigrind_client, blueprint, repo)
        @template = template
        @amigrind_client = amigrind_client
        @blueprint = blueprint
        @repo = repo
      end

      def run
        credentials = @amigrind_client.credentials

        aws_env_vars =
          case credentials.class
          when Aws::Credentials
            "AWS_ACCESS_KEY_ID='#{access_key}' AWS_SECRET_ACCESS_KEY='#{secret_key}'"
            {
              'AWS_ACCESS_KEY_ID' => credentials.access_key_id,
              'AWS_SECRET_ACCESS_KEY' => credentials.instance_variable_get(:@secret_access_key)
            }
          when Aws::SharedCredentials
            {
              'AWS_PROFILE' => credentials.profile_name,
              'AWS_DEFAULT_PROFILE' => credentials.profile_name
            }
          else
            {}
          end

        thread = nil
        retval = {
          region: @blueprint.aws.region,
          spools: { stdout: [], stderr: [] }
        }

        Dir.chdir @repo.path do
          Open3.popen3(aws_env_vars, 'packer build -machine-readable -') do |i, o, e, thr|
            thread = thr
            retval[:pid] = thread.pid

            i.write @template
            i.flush
            i.close_write

            streams = [ o, e ]

            stream_names = { o.fileno => :stdout, e.fileno => :stderr }

            until streams.find { |f| !f.eof }.nil?
              ready = IO.select(streams)

              if ready
                readable_streams = ready[0]

                readable_streams.each do |stream|
                  stream_name = stream_names[stream.fileno]

                  begin
                    data = stream.read_nonblock(8192).strip
                    debug_log data

                    retval[:spools][stream_name] << data
                    tokens = data.split(',')

                    unless tokens.empty?
                      if stream != o || tokens[2] == 'ui'
                        tokens.last.split('\n').each do |log_line|
                          info_log "packer | #{log_line.gsub('%!(PACKER_COMMA)', ',')}"
                        end
                      end

                      if tokens[2] == 'artifact' && tokens[4] == 'id'
                        retval[:amis] =
                          tokens[5].split('%!(PACKER_COMMA)').map { |pair| pair.split(':') }.to_h
                      end
                    end
                  rescue EOFError => _
                    debug_log "#{stream_name} eof"
                    streams.delete stream # this is necessary, otherwise
                  end
                end
              end
            end
          end
        end

        retval[:success] = thread.value.success?
        retval[:exit_code] = thread.value.exitstatus

        raise "ERROR: packer returned successfully, but couldn't parse AMIs?" \
          if retval[:success] && (retval[:amis].nil? || retval[:amis].empty?)

        retval
      end
    end
  end
end
