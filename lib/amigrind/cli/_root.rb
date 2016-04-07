module Amigrind
  module CLI
    # credentials = Amigrind::Core::CredentialsHelper.from_cli_options(options)

    ROOT = Cri::Command.define do
      name    File.basename($PROGRAM_NAME, ".*")
      summary "the best way to build AMIs for AWS"

      flag :h, :help, 'show help for this command' do |_, cmd|
        puts cmd.help
        exit 0
      end

      flag :v, :verbose, "debug logging instead of info" do |_, _|
        Amigrind::Core::Logging.log_level(:debug)
      end

      flag :q, :quiet, "warn logging instead of info" do |_, _|
        Amigrind::Core::Logging.log_level(:warn)
      end

      flag nil, :version, "show application version" do |_, _|
        require 'json'

        versions = {
          'amigrind' => Amigrind::VERSION,
          'amigrind-core' => Amigrind::Core::VERSION,
          'aws-sdk' => Aws::VERSION,
          'packer' => File.which('packer').nil? ? nil : `packer --version`.strip
        }

        puts JSON.pretty_generate versions

        Kernel.exit 0
      end

      run do |_, _, cmd|
        puts cmd.help
        exit 0
      end
    end
  end
end
