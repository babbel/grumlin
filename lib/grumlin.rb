# frozen_string_literal: true

require "securerandom"
require "json"

require "async"
require "async/pool"
require "async/pool/resource"
require "async/pool/controller"
require "async/queue"
require "async/barrier"
require "async/http/endpoint"
require "async/websocket/client"

require_relative "async/channel"

require_relative "grumlin/version"
require_relative "grumlin/exceptions"

require_relative "grumlin/transport"
require_relative "grumlin/client"

require_relative "grumlin/vertex"
require_relative "grumlin/edge"
require_relative "grumlin/path"
require_relative "grumlin/typing"
require_relative "grumlin/traversal"
require_relative "grumlin/request_dispatcher"
require_relative "grumlin/translator"

require_relative "grumlin/anonymous_step"
require_relative "grumlin/step"

require_relative "grumlin/t"
require_relative "grumlin/order"
require_relative "grumlin/u"
require_relative "grumlin/p"
require_relative "grumlin/pop"
require_relative "grumlin/sugar"

module Grumlin
  class Config
    attr_accessor :url, :pool_size, :client_concurrency

    # For some reason, client_concurrency must be greater than pool_size
    def initialize
      @pool_size = 10
      @client_concurrency = 20
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
