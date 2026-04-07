# frozen_string_literal: true

module CmiGateway
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class UnknownProfileError < Error; end

  class ValidationError < Error; end
end
