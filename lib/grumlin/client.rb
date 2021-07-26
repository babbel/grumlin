# frozen_string_literal: true

module Grumlin
  class Client # rubocop:disable Metrics/ClassLength
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

    def initialize(url, task: Async::Task.current)
      @task = task
      @transport = Transport::Async.new(url)
      reset!
    end

    def connect
      response_queue = @transport.connect
      @task.async { response_task(response_queue) }
    end

    def disconnect
      @transport.disconnect
      reset!
    end

    # TODO: support yielding
    def write(*args)
      request_id = SecureRandom.uuid
      queue = transport_write(to_query(request_id, args))
      wait_for_response(request_id, queue)
    ensure
      close_request(request_id)
    end

    def inspect
      "<#{self.class} url=#{@transport.url}>"
    end

    alias to_s inspect

    private

    def wait_for_response(request_id, queue, result: []) # rubocop:disable Metrics/MethodLength
      queue.each do |status, response|
        check_errors!(request_id, status, response)

        case SUCCESS[response.dig(:status, :code)]
        when :success
          return result + Typing.cast(response.dig(:result, :data))
        when :partial_content then result += Typing.cast(response.dig(:result, :data))
        when :no_content
          return []
        end
      end
    rescue ::Async::Stop
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

    def check_errors!(_request_id, status, response)
      reraise_error!(response) if status == :error

      status = response[:status]

      if (error = ERRORS[status[:code]])
        raise(error, status)
      end

      return unless SUCCESS[status[:code]].nil?

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

    def reset!
      @requests = {}
      @response_queue = nil
    end

    def close_request(request_id)
      @requests.delete(request_id)
    end

    def response_task(queue)
      queue.each do |response|
        # TODO: sometimes response does not include requestID, no idea how to handle it so far.
        response_queue = @requests[response[:requestId]]
        response_queue << [:response, response]
      end
    end

    def transport_write(request)
      Async::Queue.new.tap do |queue|
        @requests[request[:requestId]] = queue
        @transport.write(request)
      end
    end

    def ongoing_request?(request_id)
      @requests.key?(request_id)
    end
  end
end
