# frozen_string_literal: true

module Grumlin
  class RequestDispatcher
    attr_reader :requests

    SUCCESS = {
      200 => :success,
      204 => :no_content,
      206 => :partial_content
    }.freeze

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
    def add_response(response) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      request_id = response[:requestId]
      raise UnknownRequestError unless ongoing_request?(request_id)

      begin
        request = @requests[request_id]

        RequestErrorFactory.build(request, response).tap do |err|
          raise err unless err.nil?
        end

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
  end
end
