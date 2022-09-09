# frozen_string_literal: true

module Grumlin
  class Config
    attr_accessor :url, :pool_size, :client_concurrency, :client_factory, :provider

    SUPPORTED_PROVIDERS = %i[neptune tinkergraph].freeze

    DEFAULT_MIDDLEWARES = Middlewares::Builder.new do |b|
      b.use Middlewares::SerializeToSteps
      b.use Middlewares::ApplyShortcuts
      b.use Middlewares::SerializeToBytecode
      b.use Middlewares::BuildQuery
      b.use Middlewares::CastResults
      b.use Middlewares::RunQuery
    end

    class ConfigurationError < Grumlin::Error; end

    class UnknownProviderError < ConfigurationError; end

    def initialize
      @pool_size = 10
      @client_concurrency = 5
      @provider = :tinkergraph
      @client_factory = ->(url, parent) { Grumlin::Client.new(url, parent: parent) }
    end

    def middlewares
      @middlewares ||= Middlewares::Builder.new do |b|
        b.use DEFAULT_MIDDLEWARES
      end
    end

    def validate!
      return if SUPPORTED_PROVIDERS.include?(provider.to_sym)

      raise UnknownProviderError, "provider '#{provider}' is unknown. Supported providers: #{SUPPORTED_PROVIDERS}"
    end
  end
end
