# frozen_string_literal: true

require "digest"
require "base64"
require "spec_helper"

RSpec.describe CmiGateway::Checkout do
  before do
    CmiGateway.configure do |c|
      c.environment = :test
      c.client_id = "client_123"
      c.store_key = "store_key_abc"
      c.add_profile(:vc, client_id: "vc_client", store_key: "vc_store")
    end
  end

  describe ".build_hash" do
    it "matches the CMI pipe-join + SHA-512 + Base64 pipeline" do
      params = {
        "amount" => "10.00",
        "clientid" => "cid",
        "currency" => "504",
        "encoding" => "utf-8",
        "oid" => "O1",
      }
      expected_plain = +""
      params.keys.sort_by(&:downcase).each do |key|
        next if %w[hash encoding].include?(key)

        val = params[key].to_s.strip.gsub("|", "\\|").gsub("\\", "\\\\")
        expected_plain << val << "|"
      end
      expected_plain << "secret"
      expected = Base64.strict_encode64(Digest::SHA2.new(512).digest(expected_plain))

      got = described_class.build_hash(params, "secret", accent_strip: false)
      expect(got).to eq(expected)
    end

    it "applies accent map to values when accent_strip is true" do
      params = { "BillToName" => "café", "encoding" => "utf-8" }
      h1 = described_class.build_hash(params, "k", accent_strip: false)
      h2 = described_class.build_hash(params, "k", accent_strip: true)
      expect(h1).not_to eq(h2)
    end
  end

  describe "#params" do
    before do
      allow_any_instance_of(described_class).to receive(:random_rnd).and_return("fixedrndvalue")
    end

    it "builds POST fields and hash" do
      checkout = described_class.new(
        amount: 199.0,
        order_id: "ORD-1",
        ok_url: "https://example.com/ok",
        fail_url: "https://example.com/fail",
        callback_url: "https://api.example.com/cmi",
        email: "a@b.com",
        phone: "0600000000",
        bill_to_name: "Jean Dupont",
      )

      expect(checkout.action_url).to include("testpayment.cmi.co.ma")
      p = checkout.params
      expect(p["clientid"]).to eq("client_123")
      expect(p["amount"]).to eq("199.00")
      expect(p["oid"]).to eq("ORD-1")
      expect(p["callbackUrl"]).to eq("https://api.example.com/cmi")
      expect(p["rnd"]).to eq("fixedrndvalue")
      expect(p["hash"]).to be_a(String)
      expect(p["hash"].length).to be > 10
    end

    it "uses named profile credentials" do
      checkout = described_class.new(
        amount: 10,
        order_id: "X",
        ok_url: "https://example.com/ok",
        fail_url: "https://example.com/fail",
        callback_url: "https://api.example.com/cmi",
        profile: :vc,
      )
      p = checkout.params
      expect(p["clientid"]).to eq("vc_client")
    end

    it "merges extra_params" do
      checkout = described_class.new(
        amount: 10,
        order_id: "X",
        ok_url: "https://example.com/ok",
        fail_url: "https://example.com/fail",
        callback_url: "https://api.example.com/cmi",
        extra_params: { "BillToCity" => "Casablanca" },
      )
      expect(checkout.params["BillToCity"]).to eq("Casablanca")
    end
  end

  describe "validation" do
    it "raises ValidationError when credentials missing" do
      CmiGateway.reset_configuration!
      CmiGateway.configure do |c|
        c.client_id = ""
        c.store_key = ""
      end
      checkout = described_class.new(
        amount: 10,
        order_id: "X",
        ok_url: "https://example.com/ok",
        fail_url: "https://example.com/fail",
        callback_url: "https://api.example.com/cmi",
      )
      expect { checkout.params }.to raise_error(CmiGateway::ValidationError)
    end

    it "reports unknown profile in errors" do
      checkout = described_class.new(
        amount: 10,
        order_id: "X",
        ok_url: "https://example.com/ok",
        fail_url: "https://example.com/fail",
        callback_url: "https://api.example.com/cmi",
        profile: :nope,
      )
      expect(checkout.valid?).to be false
      expect(checkout.errors.join).to include("Unknown CMI profile")
    end
  end

  describe "production URL" do
    it "uses production gateway when configured" do
      CmiGateway.configure do |c|
        c.environment = :production
        c.client_id = "client_123"
        c.store_key = "store_key_abc"
      end
      checkout = described_class.new(
        amount: 1,
        order_id: "X",
        ok_url: "https://example.com/ok",
        fail_url: "https://example.com/fail",
        callback_url: "https://api.example.com/cmi",
      )
      expect(checkout.action_url).to include("payment.cmi.co.ma")
    end
  end
end
