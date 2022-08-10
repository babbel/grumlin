# frozen_string_literal: true

module Grumlin
  class Config
    attr_accessor :url, :pool_size, :client_concurrency, :client_factory, :provider

    SUPPORTED_PROVIDERS = %i[neptune tinkergraph].freeze

    class ConfigurationError < Grumlin::Error; end

    class UnknownProviderError < ConfigurationError; end

    def initialize
      @pool_size = 10
      @client_concurrency = 5
      @provider = :tinkergraph
      @client_factory = ->(url, parent) { Grumlin::Client.new(url, parent: parent) }
    end

    def validate!
      return if SUPPORTED_PROVIDERS.include?(provider.to_sym)

      raise UnknownProviderError, "provider '#{provider}' is unknown. Supported providers: #{SUPPORTED_PROVIDERS}"
    end
  end
end
