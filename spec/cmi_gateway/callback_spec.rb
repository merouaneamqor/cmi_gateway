# frozen_string_literal: true

require "spec_helper"

RSpec.describe CmiGateway::Callback do
  describe "#success?" do
    it "is true when ProcReturnCode is 00" do
      cb = described_class.new("ProcReturnCode" => "00", "Response" => "Declined")
      expect(cb).to be_success
    end

    it "is true when Response is Approved (case insensitive)" do
      cb = described_class.new("ProcReturnCode" => "05", "Response" => "approved")
      expect(cb).to be_success
    end

    it "is false otherwise" do
      cb = described_class.new("ProcReturnCode" => "05", "Response" => "Declined")
      expect(cb).not_to be_success
    end
  end

  describe "accessors" do
    it "reads oid and OrderId" do
      cb = described_class.new("oid" => "  O1  ")
      expect(cb.order_id).to eq("O1")

      cb2 = described_class.new("OrderId" => "O2")
      expect(cb2.order_id).to eq("O2")
    end

    it "exposes transaction and auth" do
      cb = described_class.new("TransId" => "T1", "AuthCode" => "A1", "ProcReturnCode" => "05", "ErrMsg" => "Nope")
      expect(cb.transaction_id).to eq("T1")
      expect(cb.auth_code).to eq("A1")
      expect(cb.error_code).to eq("05")
      expect(cb.error_message).to eq("Nope")
    end

    it "returns nil error fields on success" do
      cb = described_class.new("ProcReturnCode" => "00", "ErrMsg" => "ignored")
      expect(cb.error_code).to be_nil
      expect(cb.error_message).to be_nil
    end
  end

  describe "#[]" do
    it "stringifies keys" do
      cb = described_class.new(xid: "X")
      expect(cb["xid"]).to eq("X")
    end
  end
end
