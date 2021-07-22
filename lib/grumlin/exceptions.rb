# frozen_string_literal: true

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
end
