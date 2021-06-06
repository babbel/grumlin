# frozen_string_literal: true

module Grumlin
  module Transport
    # A transport based on https://github.com/socketry/async
    # and https://github.com/socketry/async-websocket
    class Async
      attr_reader :requests

      def initialize(url, task: ::Async::Task.current)
        @task = task
        @endpoint = ::Async::HTTP::Endpoint.parse(url)

        @requests = {}
        @query_queue = ::Async::Queue.new
      end

      def connect
        raise AlreadyConnectedError unless @connection.nil?

        @client = ::Async::WebSocket::Client.open(@endpoint)
        @connection = @client.connect(@endpoint.authority, @endpoint.path)

        @tasks_barrier = ::Async::Barrier.new(parent: @task)

        @tasks_barrier.async { query_task }
        @tasks_barrier.async { response_task }

        # rescue StandardError => e
        #   @requests.each_value do |queue|
        #     queue << [:error, e]
        #   end
        #   disconnect
      end

      def disconnect
        raise NotConnectedError if @connection.nil?

        @tasks_barrier.tasks.each(&:stop)
        @tasks_barrier.wait

        @connection.close
        @client.close

        @client = nil
        @connection = nil
        @tasks_barrier = nil

        raise ResourceLeakError, "ongoing requests list is not empty: #{@requests.count} items" unless @requests.empty?
        raise ResourceLeakError, "query queue empty: #{@query.count} items" unless @query_queue.empty?
      end

      # Raw message
      def submit(message)
        raise NotConnectedError if @connection.nil?

        uuid = message[:requestId]
        ::Async::Queue.new.tap do |queue|
          @requests[uuid] = queue
          @query_queue << message
        end
      end

      def close_request(request_id)
        @requests.delete(request_id)
      end

      def ongoing_request?(request_id)
        @requests.key?(request_id)
      end

      private

      def query_task
        @query_queue.each do |query|
          @connection.write(query)
          @connection.flush
        end
      end

      def response_task
        loop do
          response = @connection.read
          # TODO: sometimes response does not include requestID, no idea how to handle it so far.
          response_queue = @requests[response[:requestId]]
          response_queue << [:response, response]
        end
      end
    end
  end
end
