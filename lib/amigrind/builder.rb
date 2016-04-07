module Amigrind
  class Builder
    include Virtus.model
    include Amigrind::Core::Logging::Mixin

    attribute :blueprint, Amigrind::Blueprints::Blueprint
    attribute :repo, Amigrind::Repo

    def initialize(aws_credentials, blueprint, repo)
      @blueprint = blueprint
      @repo = repo

      @amigrind_client = Amigrind::Core::Client.new(@blueprint.aws.region, aws_credentials)
    end

    def build
      lint
      template = rackerize

      run(template)
    end

    def lint
      errors = []

      errors << "No channel set in the blueprint; this will result in " \
                "an image that can only be retrieved via :latest, which " \
                "you may not want." if @blueprint.build_channel.nil?

      errors.each { |e| warn_log(e) }
    end

    def rackerize
      template = Build::Rackerizer.new(@amigrind_client, @blueprint, @repo).rackerize
    end

    private

    def run(template)
      runner = Build::PackerRunner.new(template, @amigrind_client, @blueprint, @repo)

      runner.run
    end

  end
end