# cmi_gateway

[![Gem Version](https://badge.fury.io/rb/cmi_gateway.svg)](https://rubygems.org/gems/cmi_gateway)

Ruby helpers for **CMI (Centre Monétique Interbancaire)** [3D Pay Hosting](https://www.cmi.co.ma/) integration: build signed checkout form parameters (SHA-512 + Base64) and parse server callbacks.

- **RubyGems:** [rubygems.org/gems/cmi_gateway](https://rubygems.org/gems/cmi_gateway)
- **No Rails required** — uses only the Ruby standard library.
- **Multiple merchant profiles** (e.g. multiple CMI merchant accounts) via `CmiGateway.configure`.

## Installation

Add to your `Gemfile`:

```ruby
gem "cmi_gateway", "~> 0.1"
```

From GitHub instead of RubyGems (edge / contribution):

```ruby
gem "cmi_gateway", github: "merouaneamqor/cmi_gateway"
# local path during development:
# gem "cmi_gateway", path: "../cmi_gateway"
```

Then:

```bash
bundle install
```

## Configuration

```ruby
require "cmi_gateway"

CmiGateway.configure do |config|
  config.environment = :test # or :production

  config.client_id = ENV.fetch("CMI_CLIENT_ID", nil)
  config.store_key = ENV.fetch("CMI_STORE_KEY", nil)

  # Named profiles for additional CMI merchant accounts
  config.add_profile(:merchant_a,
    client_id: ENV["CMI_MERCHANT_A_CLIENT_ID"],
    store_key: ENV["CMI_MERCHANT_A_STORE_KEY"])
  config.add_profile(:merchant_b,
    client_id: ENV["CMI_MERCHANT_B_CLIENT_ID"],
    store_key: ENV["CMI_MERCHANT_B_STORE_KEY"])
end
```

In Rails, put this in `config/initializers/cmi_gateway.rb` and map `config.environment` to `Rails.env.production?`.

## Building a checkout (browser POST to CMI)

```ruby
checkout = CmiGateway::Checkout.new(
  amount: 199.00,
  order_id: "BOOK-123",
  ok_url: "https://example.com/pay/ok",
  fail_url: "https://example.com/pay/fail",
  callback_url: "https://api.example.com/webhooks/cmi",
  email: "user@example.com",
  phone: "0600000000",
  bill_to_name: "Jean Dupont",
  bill_to_street1: "12 Rue Example",
  bill_to_city: "Casablanca",
  bill_to_postal_code: "20000",
  shopurl: "https://example.com",
  lang: "fr",
  tran_type: "PreAuth",
  profile: :default,      # or any named profile (:merchant_a, :merchant_b, ...)
  accent_strip: false,   # set true for stricter accent handling on hash inputs
  extra_params: {}       # merged into signed params (string keys recommended)
)

checkout.action_url # test or production est3Dgate URL
checkout.params     # Hash including "hash" — use as hidden fields in a form POST
```

Validate before rendering:

```ruby
checkout.validate! # raises CmiGateway::ValidationError
# or
checkout.valid?
checkout.errors
```

### Low-level hash (tests / custom param sets)

```ruby
params_without_hash = { "clientid" => "...", "amount" => "10.00", "encoding" => "utf-8" }
digest = CmiGateway::Checkout.build_hash(params_without_hash, "store_key", accent_strip: false)
```

## Parsing callbacks

CMI posts form fields back to your `callbackUrl`. Success is detected the same way as common CMI samples: `ProcReturnCode == "00"` or `Response` case-insensitively equals `"Approved"`.

```ruby
callback = CmiGateway::Callback.new(request.request_parameters) # Rails
# or CmiGateway::Callback.new(params.to_unsafe_h)

callback.success?
callback.order_id
callback.transaction_id
callback.auth_code
callback.error_code   # when not successful
callback.error_message
callback.raw          # indifferent string-key hash
```

**Security note:** This gem does not verify a callback `hash` from CMI; confirm with your acquirer whether server-to-server verification is required and implement it if so.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Community

- [Contributing](CONTRIBUTING.md)
- [Code of conduct](CODE_OF_CONDUCT.md)
- [Security policy](SECURITY.md)
- [Changelog](CHANGELOG.md)
- AI assistants: see [CLAUDE.md](CLAUDE.md)

## License

MIT — see [LICENSE.txt](LICENSE.txt).
