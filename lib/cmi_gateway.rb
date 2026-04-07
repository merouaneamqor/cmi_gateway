# frozen_string_literal: true

require_relative "cmi_gateway/version"
require_relative "cmi_gateway/errors"
require_relative "cmi_gateway/profile"
require_relative "cmi_gateway/configuration"
require_relative "cmi_gateway/helpers"
require_relative "cmi_gateway/checkout"
require_relative "cmi_gateway/callback"

module CmiGateway
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
