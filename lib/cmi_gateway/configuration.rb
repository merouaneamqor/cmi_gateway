# frozen_string_literal: true

module CmiGateway
  class Configuration
    attr_accessor :environment, :client_id, :store_key
    attr_reader :named_profiles

    def initialize
      @environment = :test
      @client_id = nil
      @store_key = nil
      @named_profiles = {}
    end

    def add_profile(name, client_id:, store_key:)
      @named_profiles[name.to_sym] = Profile.new(client_id: client_id, store_key: store_key)
    end

    def profile_for(name)
      key = (name || :default).to_sym
      return default_profile if key == :default

      prof = @named_profiles[key]
      raise UnknownProfileError, "Unknown CMI profile: #{name.inspect}" if prof.nil?

      prof
    end

    def default_profile
      Profile.new(client_id: @client_id, store_key: @store_key)
    end

    def production?
      @environment.to_s.downcase == "production"
    end
  end
end
