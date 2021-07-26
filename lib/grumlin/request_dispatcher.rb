# frozen_string_literal: true

module Grumlin
  class RequestDispatcher
    attr_reader :requests

    def initialize
      @requests = {}
    end

    def add_request(request)
      Async::Queue.new.tap do |queue|
        @requests[request[:requestId]] = { result: [], queue: queue }
      end
    end

    # returns nil if the result is not built yet
    # pushes the result to the queue when it's ready
    # TODO: sometimes response does not include requestID, no idea how to handle it so far.
    def add_response(response)
      raise "ERROR" unless @requests.key?(response[:requestId])

      @requests.dig(response[:requestId], :queue) << response
    end

    def close_request(request_id)
      raise "ERROR" unless @requests.key?(request_id)

      @requests.delete(request_id)
    end
  end
end
