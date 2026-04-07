# frozen_string_literal: true

require "spec_helper"

RSpec.describe CmiGateway::Configuration do
  describe "#profile_for" do
    it "returns default profile from client_id and store_key" do
      config = described_class.new
      config.client_id = "c1"
      config.store_key = "k1"
      prof = config.profile_for(:default)
      expect(prof.client_id).to eq("c1")
      expect(prof.store_key).to eq("k1")
    end

    it "returns named profile" do
      config = described_class.new
      config.client_id = "c1"
      config.store_key = "k1"
      config.add_profile(:merchant_a, client_id: "ma1", store_key: "mk1")
      prof = config.profile_for(:merchant_a)
      expect(prof.client_id).to eq("ma1")
      expect(prof.store_key).to eq("mk1")
    end

    it "raises for unknown profile" do
      config = described_class.new
      expect { config.profile_for(:missing) }.to raise_error(CmiGateway::UnknownProfileError)
    end
  end

  describe "#production?" do
    it "is true when environment is production" do
      config = described_class.new
      config.environment = :production
      expect(config).to be_production
      config.environment = "production"
      expect(config).to be_production
    end

    it "is false for test" do
      config = described_class.new
      config.environment = :test
      expect(config).not_to be_production
    end
  end
end

RSpec.describe CmiGateway do
  describe ".configure" do
    it "yields configuration" do
      described_class.configure do |c|
        c.client_id = "x"
        c.store_key = "y"
      end
      expect(described_class.configuration.client_id).to eq("x")
      expect(described_class.configuration.store_key).to eq("y")
    end
  end
end
