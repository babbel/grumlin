# frozen_string_literal: true

module Grumlin
  class Client # rubocop:disable Metrics/ClassLength
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

    def initialize(url, task: Async::Task.current)
      @task = task
      @transport = Transport.new(url)
      reset!
    end

    def connect
      response_queue = @transport.connect
      @request_dispatcher = RequestDispatcher.new
      @task.async { response_task(response_queue) }
    end

    def disconnect
      @transport.disconnect
      reset!
    end

    def requests
      @request_dispatcher.requests
    end

    # TODO: support yielding
    def write(*args)
      request_id = SecureRandom.uuid
      queue = transport_write(to_query(request_id, args))
      wait_for_response(request_id, queue)
    ensure
      @request_dispatcher.close_request(request_id)
    end

    def inspect
      "<#{self.class} url=#{@transport.url}>"
    end

    alias to_s inspect

    private

    def wait_for_response(request_id, queue, result: []) # rubocop:disable Metrics/MethodLength
      queue.each do |response|
        check_errors!(response[:status])

        case SUCCESS[response.dig(:status, :code)]
        when :success
          return result + Typing.cast(response.dig(:result, :data))
        when :partial_content then result += Typing.cast(response.dig(:result, :data))
        when :no_content
          return []
        end
      end
    rescue Async::Stop
      retry if ongoing_request?(request_id)
      raise UnknownRequestStopped, "#{request_id} is not in the ongoing requests list"
    end

    def to_query(request_id, message)
      case message.first # TODO: properly handle unknown type of message
      when String
        string_query_message(request_id, *message)
      when Grumlin::Step
        bytecode_query_message(request_id, Translator.to_bytecode_query(message))
      end
    end

    def check_errors!(status)
      if (error = ERRORS[status[:code]])
        raise(error, status)
      end

      return unless SUCCESS[status[:code]].nil?

      raise(UnknownResponseStatus, status)
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

    def reset!
      @request_dispatcher = nil
      @response_queue = nil
    end

    def response_task(queue)
      queue.each do |response|
        @request_dispatcher.add_response(response)
      end
    end

    def transport_write(request)
      @request_dispatcher.add_request(request).tap do
        @transport.write(request)
      end
    end

    def ongoing_request?(request_id)
      @request_dispatcher.requests.key?(request_id)
    end
  end
end
