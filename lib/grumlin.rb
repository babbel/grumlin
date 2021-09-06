# frozen_string_literal: true

require "securerandom"
require "oj"

Oj.mimic_JSON
Oj.add_to_json

require "async"
require "async/pool"
require "async/pool/resource"
require "async/pool/controller"
require "async/queue"
require "async/barrier"
require "async/http/endpoint"
require "async/websocket/client"

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "rspec" => "RSpec",
  "db_cleaner_context" => "DBCleanerContext"
)

module Grumlin
  class Error < StandardError; end

  class UnknownError < Error; end

  class ConnectionError < Error; end

  class CannotConnectError < ConnectionError; end

  class DisconnectError < ConnectionError; end

  class ConnectionStatusError < Error; end

  class NotConnectedError < ConnectionStatusError; end

  class AlreadyConnectedError < ConnectionStatusError; end

  class ProtocolError < Error; end

  class UnknownResponseStatus < ProtocolError
    attr_reader :status

    def initialize(status)
      super("unknown response status code #{status[:code]}")
      @status = status
    end
  end

  class UnknownTypeError < ProtocolError; end

  class StatusError < Error
    attr_reader :status

    def initialize(status)
      super(status[:message])
      @status = status
    end
  end

  class ClientSideError < StatusError; end

  class ServerSideError < StatusError; end

  class ScriptEvaluationError < ServerSideError; end

  class InvalidRequestArgumentsError < ServerSideError; end

  class ServerError < ServerSideError; end

  class ServerSerializationError < ServerSideError; end

  class ServerTimeoutError < ServerSideError; end

  class InternalClientError < Error; end

  class UnknownRequestStoppedError < InternalClientError; end

  class ResourceLeakError < InternalClientError; end

  class UnknownMapKey < InternalClientError
    attr_reader :key, :map

    def initialize(key, map)
      @key = key
      @map = map
      super("Cannot cast key #{key} in map #{map}")
    end
  end

  class Config
    attr_accessor :url, :pool_size, :client_concurrency, :client_factory

    def initialize
      @pool_size = 10
      @client_concurrency = 5
      @client_factory = ->(url, parent) { Grumlin::Client.new(url, parent: parent) }
    end

    def default_pool
      @default_pool ||= Async::Pool::Controller.new(Grumlin::Client::PoolResource, limit: pool_size)
    end

    def reset!
      @default_pool = nil
    end
  end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end
  end
end

loader.setup
loader.eager_load
