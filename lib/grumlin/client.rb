# frozen_string_literal: true

module Grumlin
  class Client
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
      @transport.connect if autoconnect
    end

    def disconnect
      @transport.disconnect
    end

    # TODO: support yielding
    def query(*args) # rubocop:disable Metrics/MethodLength
      result = []

      uuid, queue = submit_query(args)
      queue.each do |status, response|
        reraise_error!(response) if status == :error

        check_errors!(response[:status])

        case SUCCESS[response.dig(:status, :code)]
        when :success
          return result + Typing.cast(response.dig(:result, :data))
        when :partial_content
          result += Typing.cast(response.dig(:result, :data))
        when :no_content
          return []
        end
      ensure
        @transport.close_request(uuid)
      end
    end

    def requests
      @transport.requests
    end

    private

    def submit_query(args, &block)
      uuid = SecureRandom.uuid
      [uuid, @transport.submit(to_query(uuid, args), &block)]
    end

    def to_query(uuid, message)
      case message.first
      when String
        string_query_message(uuid, *message)
      when Grumlin::Step
        bytecode_query_message(uuid, Translator.to_bytecode_query(message))
      end
    end

    def check_errors!(status)
      error = ERRORS[status[:code]]
      raise(error, status) if error

      raise UnknownResponseStatus, status if SUCCESS[status[:code]].nil?
    end

    def reraise_error!(error)
      raise error
    rescue StandardError
      raise ConnectionError
    end

    def string_query_message(uuid, query, bindings)
      {
        requestId: uuid,
        op: "eval",
        processor: "",
        args: {
          gremlin: query,
          bindings: bindings,
          language: "gremlin-groovy"
        }
      }
    end

    def bytecode_query_message(uuid, bytecode)
      {
        requestId: uuid,
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
