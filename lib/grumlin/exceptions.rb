# frozen_string_literal: true

module Grumlin
  class Error < StandardError; end

  class ConnectionError < Error; end

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

  class ConnectionClosedError < Error; end

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
end
