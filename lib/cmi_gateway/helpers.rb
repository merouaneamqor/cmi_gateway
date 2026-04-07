# frozen_string_literal: true

module CmiGateway
  module Helpers
    module_function

    ACCENT_MAP = "àâçèéêîôùû"
    ACCENT_REP = "aaceeeiouu"

    # CMI amount format: two decimal places.
    def format_amount(value)
      numeric = case value
                when String then BigDecimal(value)
                when Integer, Float, BigDecimal then BigDecimal(value.to_s)
                else BigDecimal("0")
                end
      format("%.2f", numeric)
    end

    # Hash pipeline: strip, escape | then \ (order matches CMI integration gist).
    def escape_hash_component(value)
      value.to_s.strip.gsub("|", "\\|").gsub("\\", "\\\\")
    end

    def apply_accent_map(value)
      value.to_s.tr(ACCENT_MAP, ACCENT_REP)
    end

    # ASCII-ish name for BillTo fields (no Rails I18n).
    def transliterate_name(name)
      base = name.to_s.strip
      return "" if base.empty?

      base.unicode_normalize(:nfkd).encode("ASCII", invalid: :replace, undef: :replace, replace: "")
           .gsub(/[^0-9A-Za-z ]/, " ")
           .squeeze(" ")
           .strip
    end

    # Street-style sanitization: transliterate then strip non-alphanumeric except space.
    def transliterate_street(address)
      base = address.to_s.strip
      return "" if base.empty?

      base.unicode_normalize(:nfkd).encode("ASCII", invalid: :replace, undef: :replace, replace: "")
           .gsub(/[^0-9A-Za-z ]/, "")
           .squeeze(" ")
           .strip
    end
  end
end
