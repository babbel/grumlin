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

    VERTEX_ALREADY_EXISTS = "Vertex with id already exists:"
    EDGE_ALREADY_EXISTS = "Edge with id already exists:"
    CONCURRENT_VERTEX_INSERT_FAILED = "Failed to complete Insert operation for a Vertex due to conflicting concurrent"
    CONCURRENT_EDGE_INSERT_FAILED = "Failed to complete Insert operation for an Edge due to conflicting concurrent"

    class DispatcherError < Grumlin::Error; end

    class RequestAlreadyAddedError < DispatcherError; end

    class UnknownRequestError < DispatcherError; end

    def initialize
      @requests = {}
    end

    def add_request(request)
      raise RequestAlreadyAddedError if @requests.include?(request[:requestId])

      Async::Channel.new.tap do |channel|
        @requests[request[:requestId]] = { request: request, result: [], channel: channel }
      end
    end

    # builds a response object, when it's ready sends it to the client via a channel
    # TODO: sometimes response does not include requestID, no idea how to handle it so far.
    def add_response(response) # rubocop:disable Metrics/AbcSize
      request_id = response[:requestId]
      raise UnknownRequestError unless ongoing_request?(request_id)

      begin
        request = @requests[request_id]

        check_errors!(response[:status], request[:request])

        case SUCCESS[response.dig(:status, :code)]
        when :success
          request[:result] << response.dig(:result, :data)
          request[:channel] << request[:result]
          close_request(request_id)
        when :partial_content then request[:result] << response.dig(:result, :data)
        when :no_content
          request[:channel] << []
          close_request(request_id)
        end
      rescue StandardError => e
        request[:channel].exception(e)
        close_request(request_id)
      end
    end

    def ongoing_request?(request_id)
      @requests.include?(request_id)
    end

    def clear
      @requests.each do |_id, request|
        request[:channel].close!
      end
      @requests.clear
    end

    private

    def close_request(request_id)
      raise UnknownRequestError unless ongoing_request?(request_id)

      request = @requests.delete(request_id)
      request[:channel].close
    end

    def check_errors!(status, query)
      if (error = ERRORS[status[:code]])
        raise (
          already_exists_error(status) ||
          concurrent_insert_error(status) ||
          error
        ).new(status, query)
      end

      return unless SUCCESS[status[:code]].nil?

      raise(UnknownResponseStatus, status)
    end

    def already_exists_error(status)
      return VertexAlreadyExistsError if status[:message]&.include?(VERTEX_ALREADY_EXISTS)
      return EdgeAlreadyExistsError if status[:message]&.include?(EDGE_ALREADY_EXISTS)
    end

    def concurrent_insert_error(status)
      return ConcurrentVertexInsertFailedError if status[:message]&.include?(CONCURRENT_VERTEX_INSERT_FAILED)
      return ConcurrentEdgeInsertFailedError if status[:message]&.include?(CONCURRENT_EDGE_INSERT_FAILED)
    end
  end
end
