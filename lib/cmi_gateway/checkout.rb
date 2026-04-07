# frozen_string_literal: true

require "digest"
require "base64"
require "bigdecimal"

module CmiGateway
  class Checkout
    STORE_TYPE = "3D_PAY_HOSTING"
    DEFAULT_HASH_ALGORITHM = "ver3"
    DEFAULT_ENCODING = "utf-8"
    DEFAULT_LANG = "fr"
    DEFAULT_TRAN_TYPE = "PreAuth"
    DEFAULT_CURRENCY = "504"
    DEFAULT_COUNTRY = "504"

    PRODUCTION_URL = "https://payment.cmi.co.ma/fim/est3Dgate"
    TEST_URL = "https://testpayment.cmi.co.ma/fim/est3Dgate"

    attr_reader :accent_strip, :profile_name

    def initialize(
      amount:,
      order_id:,
      ok_url:,
      fail_url:,
      callback_url:,
      currency: DEFAULT_CURRENCY,
      lang: DEFAULT_LANG,
      tran_type: DEFAULT_TRAN_TYPE,
      email: nil,
      phone: nil,
      bill_to_name: nil,
      bill_to_street1: nil,
      bill_to_city: nil,
      bill_to_postal_code: nil,
      bill_to_country: DEFAULT_COUNTRY,
      shopurl: nil,
      accent_strip: false,
      profile: :default,
      extra_params: {},
      configuration: nil
    )
      @amount = amount
      @order_id = order_id
      @ok_url = ok_url
      @fail_url = fail_url
      @callback_url = callback_url
      @currency = currency
      @lang = lang
      @tran_type = tran_type
      @email = email
      @phone = phone
      @bill_to_name = bill_to_name
      @bill_to_street1 = bill_to_street1
      @bill_to_city = bill_to_city
      @bill_to_postal_code = bill_to_postal_code
      @bill_to_country = bill_to_country
      @shopurl = shopurl
      @accent_strip = accent_strip
      @profile_name = profile
      @extra_params = stringify_keys(extra_params || {})
      @configuration = configuration || CmiGateway.configuration
    end

    def action_url
      @configuration.production? ? PRODUCTION_URL : TEST_URL
    end

    def params
      @params ||= build_signed_params
    end

    def valid?
      errors.empty?
    end

    def validate!
      raise ValidationError, errors.join(", ") unless valid?

      self
    end

    def errors
      @errors ||= begin
        errs = []
        errs << "amount is required" if @amount.nil? && !@extra_params.key?("amount")
        errs << "order_id is required" if @order_id.to_s.strip.empty?
        errs << "ok_url is required" if @ok_url.to_s.strip.empty?
        errs << "fail_url is required" if @fail_url.to_s.strip.empty?
        errs << "callback_url is required" if @callback_url.to_s.strip.empty?
        begin
          prof = @configuration.profile_for(@profile_name)
          errs << "CMI client_id is missing for profile #{@profile_name.inspect}" if prof.client_id.to_s.strip.empty?
          errs << "CMI store_key is missing for profile #{@profile_name.inspect}" if prof.store_key.to_s.strip.empty?
        rescue UnknownProfileError => e
          errs << e.message
        end
        errs
      end
    end

    def self.build_hash(params, store_key, accent_strip: false)
      plain = +""
      params.keys.sort_by(&:downcase).each do |key|
        next if %w[hash encoding].include?(key)

        val = params[key].to_s.strip
        val = val.tr(Helpers::ACCENT_MAP, Helpers::ACCENT_REP) if accent_strip
        plain << Helpers.escape_hash_component(val) << "|"
      end
      plain << store_key.to_s

      Base64.strict_encode64(Digest::SHA2.new(512).digest(plain))
    end

    private

    def profile
      @profile ||= @configuration.profile_for(@profile_name)
    end

    def build_signed_params
      validate!

      amount_value = @amount.nil? ? @extra_params["amount"] : @amount

      base = {
        "clientid" => profile.client_id.to_s,
        "storetype" => STORE_TYPE,
        "TranType" => @tran_type.to_s,
        "amount" => Helpers.format_amount(amount_value),
        "currency" => @currency.to_s,
        "oid" => @order_id.to_s,
        "okUrl" => @ok_url.to_s,
        "failUrl" => @fail_url.to_s,
        "callbackUrl" => @callback_url.to_s,
        "lang" => @lang.to_s,
        "rnd" => random_rnd,
        "hashAlgorithm" => DEFAULT_HASH_ALGORITHM,
        "encoding" => DEFAULT_ENCODING,
        "callBackResponse" => "true",
      }

      base["email"] = @email.to_s if @email
      base["tel"] = @phone.to_s if @phone
      base["BillToName"] = format_name(@bill_to_name) if @bill_to_name
      base["BillToStreet1"] = format_street(@bill_to_street1) if @bill_to_street1
      base["BillToCity"] = @bill_to_city.to_s.strip if @bill_to_city
      base["BillToPostalCode"] = @bill_to_postal_code.to_s if @bill_to_postal_code
      base["BillToCountry"] = @bill_to_country.to_s
      base["shopurl"] = @shopurl.to_s if @shopurl

      merged = base.merge(@extra_params)
      hash = self.class.build_hash(merged, profile.store_key, accent_strip: @accent_strip)
      merged.merge("hash" => hash)
    end

    def random_rnd
      rand(36**17).to_s(36)
    end

    def format_name(name)
      base = name.to_s.strip
      return "" if base.empty?

      ascii = base.unicode_normalize(:nfkd).encode("ASCII", invalid: :replace, undef: :replace, replace: "")
      ascii = Helpers.apply_accent_map(ascii) if @accent_strip
      ascii.strip
    end

    def format_street(address)
      base = Helpers.transliterate_street(address)
      base = Helpers.apply_accent_map(base) if @accent_strip
      base
    end

    def stringify_keys(hash)
      hash.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end
  end
end
