# frozen_string_literal: true

module CmiGateway
  class Profile
    attr_reader :client_id, :store_key

    def initialize(client_id:, store_key:)
      @client_id = client_id
      @store_key = store_key
    end

    def complete?
      !client_id.to_s.strip.empty? && !store_key.to_s.strip.empty?
    end
  end
end
