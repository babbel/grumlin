# frozen_string_literal: true

module Grumlin
  class Client
    extend Forwardable

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

    def initialize(url, autoconnect: true)
      @url = url
      @transport = Transport::Async.new(url)
      connect if autoconnect
    end

    def_delegators :@transport, :connect, :disconnect, :requests

    # TODO: support yielding
    def submit(*args)
      request_id, queue = submit_query(args)
      wait_for_response(request_id, queue)
    end

    private

    def wait_for_response(request_id, queue, result: []) # rubocop:disable Metrics/MethodLength
      queue.each do |status, response|
        check_errors!(request_id, status, response)

        case SUCCESS[response.dig(:status, :code)]
        when :success
          @transport.close_request(request_id)
          return result + Typing.cast(response.dig(:result, :data))
        when :partial_content then result += Typing.cast(response.dig(:result, :data))
        when :no_content
          @transport.close_request(request_id)
          return []
        end
      end
    rescue ::Async::Stop
      retry if @transport.ongoing_request?(request_id)
      raise UnknownRequestStopped, "#{request_id} is not in the ongoing requests list"
    end

    def submit_query(args, &block)
      request_id = SecureRandom.uuid
      [request_id, @transport.submit(to_query(request_id, args), &block)]
    end

    def to_query(request_id, message)
      case message.first
      when String
        string_query_message(request_id, *message)
      when Grumlin::Step
        bytecode_query_message(request_id, Translator.to_bytecode_query(message))
      end
    end

    def check_errors!(request_id, status, response) # rubocop:disable Metrics/MethodLength
      if status == :error
        @transport.close_request(request_id)
        reraise_error!(response)
      end

      status = response[:status]

      if (error = ERRORS[status[:code]])
        @transport.close_request(request_id)
        raise(error, status)
      end

      return unless SUCCESS[status[:code]].nil?

      @transport.close_request(request_id)
      raise(UnknownResponseStatus, status)
    end

    def reraise_error!(error)
      raise error
    rescue StandardError
      raise UnknownError
    end

    def string_query_message(request_id, query, bindings)
      {
        requestId: request_id,
        op: "eval",
        processor: "",
        args: {
          gremlin: query,
          bindings: bindings,
          language: "gremlin-groovy"
        }
      }
    end

    def bytecode_query_message(request_id, bytecode)
      {
        requestId: request_id,
        op: "bytecode",
        processor: "traversal",
        args: {
          gremlin: Typing.to_bytecode(bytecode),
          aliases: { g: :g }
        }
      }
    end
  end
end
