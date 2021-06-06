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

    def initialize(url, autoconnect: true)
      @url = url
      @transport = Transport::Async.new(url)
      connect if autoconnect
    end

    def connect
      p("Connecting")
      @transport.connect
      p("Connected")
    end

    def disconnect
      p("Disconnecting")
      @transport.disconnect
      p("Disconnected")
    end

    # TODO: support yielding
    def query(*args)
      request_id, queue = submit_query(args)
      wait_for_response(request_id, queue)
    end

    def requests
      @transport.requests
    end

    private

    def wait_for_response(request_id, queue, result: [], stopping: false) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
      p("#{request_id} Stopping") if stopping
      queue.each do |status, response|
        p("#{request_id} #{response.dig(:status, :code)}") if stopping
        check_errors!(request_id, status, response)

        case SUCCESS[response.dig(:status, :code)]
        when :success
          @transport.close_request(request_id)
          p("#{request_id} returning") if stopping
          return result + Typing.cast(response.dig(:result, :data))
        when :partial_content then result += Typing.cast(response.dig(:result, :data))
        when :no_content
          @transport.close_request(request_id)
          return []
        end
      end
    rescue ::Async::Stop
      if @transport.ongoing_request?(request_id)
        stopping = true
        p("#{request_id} retrying")
        retry
      end
      p("#{request_id} #{requests}")
      nil
    end

    def submit_query(args, &block)
      request_id = SecureRandom.uuid
      [request_id, @transport.submit(to_query(request_id, args), &block)]
    rescue ::Async::Stop
      p("submit_query stoppend")
      raise
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
      raise ConnectionError
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
