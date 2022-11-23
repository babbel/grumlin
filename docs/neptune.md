# AWS Neptune

Using AWS neptune with IAM authentication enabled requires some additional configuration. You'd need
to provide `Grumlin` with a customized `Grumlin::Client` that is aware of authentication:
```ruby
# authenticated_client.rb

class AuthenticatedClient < Grumlin::Client
  SERVICE = "neptune-db"
  METHOD = "GET"

  def initialize(url, region:, parent: Async::Task.current)
    @url = url
    @region = region
    super(@url, parent:)
  end

  def write(*, **)
    connect unless connected?
    super
  end

  private

  def signer
    @signer ||= Aws::Sigv4::Signer.new(service: SERVICE,
                                       region: @region,
                                       credentials_provider:,
                                       apply_checksum_header: false)
  end

  def credentials_provider
    @credentials_provider ||= Aws::CredentialProviderChain.new.resolve
  end

  def signed_headers
    signer.sign_request(
      http_method: METHOD,
      url: @url
    ).headers.except("host")
  end

  # Override
  def build_transport
    Grumlin::Transport.new(@url, parent: @parent, headers: signed_headers)
  end
end
```


```ruby
# config/initializers/grumlin.rb

Grumlin.configure do |config|
  config.url = ENV.fetch("GREMLIN_URL")

  if ENV.fetch("GREMLIN_USE_IAM")
    config.provider = :neptune if ENV.fetch("NEPTUNE_REGION") != "local"

    config.client_factory = lambda do |url, parent|
      AuthenticatedClient.new(url, region: ENV.fetch("NEPTUNE_REGION"), parent:)
    end
  end
end
```
