# frozen_string_literal: true

require_relative "lib/cmi_gateway/version"

Gem::Specification.new do |spec|
  spec.name = "cmi_gateway"
  spec.version = CmiGateway::VERSION
  spec.authors = ["AMQOR MEROUANE"]
  spec.email = ["marouaneamqor@gmail.com"]

  spec.summary = "CMI (Morocco) 3D Pay Hosting checkout signing and callback parsing"
  spec.description = "Builds CMI payment form parameters and SHA-512 hash; parses server callbacks."
  spec.homepage = "https://github.com/marouaneamqor/cmi_gateway"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*.rb"].concat(%w[README.md LICENSE.txt])
  spec.bindir = "exe"
  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.60"
end
