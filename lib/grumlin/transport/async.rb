# frozen_string_literal: true

module Grumlin
  module Transport
    # A transport based on https://github.com/socketry/async
    # and https://github.com/socketry/async-websocket
    class Async
      def initialize(url, task: ::Async::Task.current)
        @task = task
        @url = url

        @requests = {}
        @query_queue = ::Async::Queue.new
      end

      def connect # rubocop:disable Metrics/MethodLength
        raise AlreadyConnectedError unless @connection_task.nil?

        @connection_task = @task.async do |subtask|
          endpoint = ::Async::HTTP::Endpoint.parse(@url)
          ::Async::WebSocket::Client.connect(endpoint) do |connection|
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

      # Raw message
      def submit(message)
        uuid = message[:requestId]
        @requests[uuid] = ::Async::Queue.new
        @query_queue << message

        @requests[uuid].each do |response|
          yield(*response)
        end
      end

      def close_request(request_id)
        @requests.delete(request_id)
      end

      private

      def query_task(connection)
        loop do
          connection.write @query_queue.dequeue
          connection.flush
        end
      end

      def response_task(connection)
        loop do
          response = connection.read
          # TODO: sometimes response does not include requestID, now idea how to handle it so far.
          response_queue = @requests[response[:requestId]]
          response_queue << [:response, response]
        end
      end
    end
  end
end
