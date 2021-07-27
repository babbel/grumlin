# frozen_string_literal: true

module Grumlin
  class RequestDispatcher
    attr_reader :requests

    SUCCESS = {
      200 => :success,
      204 => :no_content,
      206 => :partial_content
    }.freeze

    ERRORS = {
      499 => InvalidRequestArgumentsError,
      500 => ServerError,
      597 => ScriptEvaluationError,
      599 => ServerSerializationError,
      598 => ServerTimeoutError,

      401 => ClientSideError,
      407 => ClientSideError,
      498 => ClientSideError
    }.freeze

    def initialize
      @requests = {}
    end

    def add_request(request)
      raise "ERROR" if @requests.key?(request[:requestId])

      Async::Queue.new.tap do |queue|
        @requests[request[:requestId]] = { request: request, result: [], queue: queue }
      end
    end

    # builds a response object, when it's ready sends it to the client via a queue
    # TODO: sometimes response does not include requestID, no idea how to handle it so far.
    def add_response(response) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      request_id = response[:requestId]
      raise "ERROR" unless @requests.key?(request_id)

      request = @requests[request_id]

      check_errors!(response[:status])

      case SUCCESS[response.dig(:status, :code)]
      when :success
        request[:queue] << [:result, request[:result] + [response.dig(:result, :data)]]
        close_request(request_id)
      when :partial_content then request[:result] << response.dig(:result, :data)
      when :no_content
        request[:queue] << [:result, []]
        close_request(request_id)
      end
    rescue StandardError => e
      request[:queue] << [:error, e]
      close_request(request_id)
    end

    def close_request(request_id)
      raise "ERROR" unless @requests.key?(request_id)

      @requests.delete(request_id)
    end

    private

    def check_errors!(status)
      if (error = ERRORS[status[:code]])
        raise(error, status)
      end

      return unless SUCCESS[status[:code]].nil?

      raise(UnknownResponseStatus, status)
    end
  end
end