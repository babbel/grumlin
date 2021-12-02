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

db_adapters = "#{__dir__}/grumlin/test"
loader.do_not_eager_load(db_adapters)

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
    attr_reader :status, :query

    def initialize(status, query)
      super(status[:message])
      @status = status
      @query = query
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
  end

  def self.supported_steps
    @supported_steps ||= (Grumlin::AnonymousStep::SUPPORTED_STEPS + Grumlin::Tools::U::SUPPORTED_STEPS).sort.uniq
  end

  @pool_mutex = Mutex.new

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end

    def default_pool
      if Thread.current.thread_variable_get(:grumlin_default_pool)
        return Thread.current.thread_variable_get(:grumlin_default_pool)
      end

      @pool_mutex.synchronize do
        Thread.current.thread_variable_set(:grumlin_default_pool,
                                           Async::Pool::Controller.new(Grumlin::Client::PoolResource,
                                                                       limit: config.pool_size))
      end
    end

    def close
      return if Thread.current.thread_variable_get(:grumlin_default_pool).nil?

      @pool_mutex.synchronize do
        pool = Thread.current.thread_variable_get(:grumlin_default_pool)
        pool.wait while pool.busy?
        pool.close
        Thread.current.thread_variable_set(:grumlin_default_pool, nil)
      end
    end
  end
end

loader.setup
loader.eager_load
