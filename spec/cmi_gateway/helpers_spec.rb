# frozen_string_literal: true

require "spec_helper"

RSpec.describe CmiGateway::Helpers do
  describe ".format_amount" do
    it "formats integers with two decimals" do
      expect(described_class.format_amount(10)).to eq("10.00")
    end

    it "formats BigDecimal and strings" do
      expect(described_class.format_amount(BigDecimal("19.9"))).to eq("19.90")
      expect(described_class.format_amount("7.5")).to eq("7.50")
    end
  end

  describe ".escape_hash_component" do
    it "escapes pipe and backslash in CMI order" do
      expect(described_class.escape_hash_component("a|b")).to eq("a\\|b")
      expect(described_class.escape_hash_component("a\\b")).to eq("a\\\\b")
    end

    it "strips whitespace" do
      expect(described_class.escape_hash_component("  x  ")).to eq("x")
    end
  end

  describe ".apply_accent_map" do
    it "maps French accents" do
      expect(described_class.apply_accent_map("café")).to eq("cafe")
    end
  end

  describe ".transliterate_street" do
    it "strips non-alphanumeric characters except spaces" do
      expect(described_class.transliterate_street("12 Rue d'Agadir!")).to include("12")
      expect(described_class.transliterate_street("12 Rue d'Agadir!")).not_to include("!")
    end
  end
end
