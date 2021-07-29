# frozen_string_literal: true

module Grumlin
  class Transport
    # A transport based on https://github.com/socketry/async
    # and https://github.com/socketry/async-websocket
    def initialize(url, parent: Async::Task.current)
      @endpoint = Async::HTTP::Endpoint.parse(url)
      @parent = parent
      @request_queue = Async::Queue.new
      @response_queue = Async::Queue.new
      reset!
    end

    def url
      @endpoint.url
    end

    def connected?
      @connected
    end

    def connect # rubocop:disable Metrics/MethodLength
      raise AlreadyConnectedError if connected?

      @connection = Async::WebSocket::Client.connect(@endpoint)

      @response_task = @parent.async do
        loop do
          data = @connection.read
          @response_queue << data
        end
      rescue Async::Stop
        @response_queue << nil
      end

      @request_task = @parent.async do
        @request_queue.each do |message|
          @connection.write(message)
          @connection.flush
        end
      end

      @connected = true

      @response_queue
    end

    def write(message)
      raise NotConnectedError unless connected?

      @request_queue << message
    end

    def close
      raise NotConnectedError unless connected?

      @request_queue << nil
      @request_task.wait

      @response_task.stop
      @response_task.wait

      @connection.close

      reset!
    end

    private

    def reset!
      @connected = false
      @connection = nil
      @response_task = nil
      @request_task = nil
    end
  end
end
