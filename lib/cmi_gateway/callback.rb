# frozen_string_literal: true

module CmiGateway
  class Callback
    attr_reader :raw

    def initialize(params)
      @raw = stringify_keys(params)
    end

    def success?
      code = @raw["ProcReturnCode"].to_s
      response = @raw["Response"].to_s
      code == "00" || response.casecmp("Approved").zero?
    end

    def order_id
      o = @raw["oid"].to_s.strip
      return o unless o.empty?

      o2 = @raw["OrderId"].to_s.strip
      o2.empty? ? nil : o2
    end

    def transaction_id
      t = @raw["TransId"].to_s.strip
      t.empty? ? nil : t
    end

    def auth_code
      a = @raw["AuthCode"].to_s.strip
      a.empty? ? nil : a
    end

    def error_code
      return nil if success?

      c = @raw["ProcReturnCode"].to_s.strip
      c.empty? ? nil : c
    end

    def error_message
      return nil if success?

      m = @raw["ErrMsg"].to_s.strip
      m.empty? ? nil : m
    end

    def [](key)
      @raw[key.to_s]
    end

    private

    def stringify_keys(params)
      return {} if params.nil?

      params.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end
  end
end
