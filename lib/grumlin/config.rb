# frozen_string_literal: true

class Grumlin::Config
  attr_accessor :url, :pool_size, :client_concurrency, :client_factory, :provider

  SUPPORTED_PROVIDERS = [:neptune, :tinkergraph].freeze

  DEFAULT_MIDDLEWARES = Grumlin::Middlewares::Builder.new do |b|
    b.use Grumlin::Middlewares::SerializeToSteps
    b.use Grumlin::Middlewares::ApplyShortcuts
    b.use Grumlin::Middlewares::SerializeToBytecode
    b.use Grumlin::Middlewares::BuildQuery
    b.use Grumlin::Middlewares::CastResults
    b.use Grumlin::Middlewares::RunQuery
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
    @middlewares ||= Grumlin::Middlewares::Builder.new do |b|
      b.use DEFAULT_MIDDLEWARES
    end
    yield(@middlewares) if block_given?
    @middlewares
  end

  def validate!
    return if SUPPORTED_PROVIDERS.include?(provider.to_sym)

    raise UnknownProviderError, "provider '#{provider}' is unknown. Supported providers: #{SUPPORTED_PROVIDERS}"
  end
end
