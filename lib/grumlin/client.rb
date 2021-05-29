# frozen_string_literal: true

module Grumlin
  class Client
    SUCCESS_STATUS = 200
    NO_CONTENT_STATUS = 204
    PARTIAL_CONTENT_STATUS = 206

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

      @requests = {}
      @query_queue = Async::Queue.new

      @transport.connect if autoconnect
    end

    def disconnect
      @transport.disconnect
    end

    def query(*args) # rubocop:disable Metrics/MethodLength
      result = []

      submit_query(args) do |status, response|
        request_id = response[:requestId]
        reraise_error!(response) if status == :error

        status = response[:status]

        if status[:code] == NO_CONTENT_STATUS
          @transport.close_request(request_id)
          return []
        end
        check_errors!(status, request_id)

        page = Typing.cast(response.dig(:result, :data))

        case status[:code]
        when SUCCESS_STATUS
          @transport.close_request(request_id)
          return result + page
        when PARTIAL_CONTENT_STATUS
          result += page
        else
          raise UnknownResponseStatus, status
        end
      end
    end

    private

    def submit_query(args, &block)
      SecureRandom.uuid.tap do |uuid|
        @transport.submit(to_query(uuid, args), &block)
      end
    end

    def to_query(uuid, message)
      case message.first
      when String
        string_query_message(uuid, *message)
      when Grumlin::Step
        bytecode_query_message(uuid, Translator.to_bytecode_query(message))
      end
    end

    def check_errors!(status, request_id)
      error = ERRORS[status[:code]]
      @transport.close_request(request_id)
      raise(error, status) if error
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
