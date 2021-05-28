# frozen_string_literal: true

module Grumlin
  class Client # rubocop:disable Metrics/ClassLength
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

    def initialize(url, task: Async::Task.current, autoconnect: true, mode: :bytecode)
      @task = task
      @endpoint = Async::HTTP::Endpoint.parse(url)
      @mode = mode

      @requests = {}
      @query_queue = Async::Queue.new

      connect if autoconnect
    end

    def connect # rubocop:disable Metrics/MethodLength
      raise AlreadyConnectedError unless @connection_task.nil?

      @connection_task = @task.async do |subtask|
        Async::WebSocket::Client.connect(@endpoint) do |connection|
          subtask.async { query_task(connection) }
          response_task(connection)
        end
      rescue StandardError => e
        @requests.each_value do |queue|
          queue << [:error, e]
        end
        disconnect
      end
    end

    def disconnect
      raise NotConnectedError if @connection_task.nil?

      @connection_task&.stop
      @connection_task&.wait
      @connection_task = nil
      @requests = {}
    end

    def query(*args) # rubocop:disable Metrics/MethodLength
      response_queue, request_id = schedule_query(args)
      result = []

      response_queue.each do |status, response|
        reraise_error!(response) if status == :error

        status = response[:status]

        if status[:code] == NO_CONTENT_STATUS
          close_request(request_id)
          return []
        end
        check_errors!(status, request_id) # rescue binding.irb

        page = Typing.cast(response.dig(:result, :data))

        case status[:code]
        when SUCCESS_STATUS
          close_request(request_id)
          return result + page
        when PARTIAL_CONTENT_STATUS
          result += page
        else
          raise UnknownResponseStatus, status
        end
      end
    end

    private

    def schedule_query(args)
      uuid = SecureRandom.uuid
      queue = Async::Queue.new
      @requests[uuid] = queue
      @query_queue << to_query(uuid, args)

      [queue, uuid]
    end

    def to_query(uuid, message)
      case message.first
      when String
        string_query_message(uuid, *message)
      when Grumlin::Step
        build_query(uuid, message)
      end
    end

    def check_errors!(status, request_id)
      error = ERRORS[status[:code]]
      close_request(request_id)
      raise(error, status) if error
    end

    def close_request(request_id)
      @requests.delete(request_id)
    end

    def reraise_error!(error)
      raise error
      # rescue StandardError
      #   raise ConnectionError
    end

    def query_task(connection)
      loop do
        connection.write @query_queue.dequeue
        connection.flush
      end
    end

    def response_task(connection)
      loop do
        response = connection.read
        response_queue = @requests[response[:requestId]]
        response_queue << [:response, response]
      end
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
          gremlin: { "@type": "g:Bytecode", "@value": { step: bytecode } },
          aliases: { g: :g }
        }
      }
    end

    def build_query(uuid, steps)
      case @mode
      when :string
        string_query_message(uuid, *Translator.to_string_query(steps))
      else
        bytecode_query_message(uuid, Translator.to_bytecode_query(steps))
      end
    end
  end
end
