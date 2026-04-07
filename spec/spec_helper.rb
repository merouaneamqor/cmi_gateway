# frozen_string_literal: true

require "bundler/setup"
require "cmi_gateway"

RSpec.configure do |config|
  config.order = :random

  config.after do
    CmiGateway.reset_configuration!
  end
end
