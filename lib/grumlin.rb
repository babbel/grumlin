# frozen_string_literal: true

require "securerandom"
require "json"

require "async"
require "async/queue"
require "async/barrier"
require "async/http/endpoint"
require "async/websocket/client"

require_relative "grumlin/version"
require_relative "grumlin/exceptions"

require_relative "grumlin/transport/async"

require_relative "grumlin/vertex"
require_relative "grumlin/edge"
require_relative "grumlin/path"
require_relative "grumlin/typing"
require_relative "grumlin/client"
require_relative "grumlin/traversal"

require_relative "grumlin/anonymous_step"
require_relative "grumlin/step"

require_relative "grumlin/translator"
require_relative "grumlin/t"
require_relative "grumlin/order"
require_relative "grumlin/u"
require_relative "grumlin/pop"
require_relative "grumlin/sugar"

module Grumlin
  class Config
    attr_accessor :url

    def default_client
      @default_client ||= Grumlin::Client.new(url)
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
