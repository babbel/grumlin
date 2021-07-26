# frozen_string_literal: true

module Grumlin
  class Transport
    # A transport based on https://github.com/socketry/async
    # and https://github.com/socketry/async-websocket
    # Version 2
    def initialize(url, task: Async::Task.current)
      @endpoint = Async::HTTP::Endpoint.parse(url)
      @task = task
      reset!
    end

    def url
      @endpoint.url
    end

    def connected?
      @connected
    end

    def connect
      @client = Async::WebSocket::Client.open(@endpoint)
      @connection = @client.connect(@endpoint.authority, @endpoint.path)
      @response_queue = Async::Queue.new

      @listen_task = @task.async do
        loop do
          @response_queue << @connection.read
        end
      end

      @connected = true

      @response_queue
    end

    def write(message)
      raise NotConnectedError unless connected?

      @connection.write(message)
      @connection.flush
    end

    def disconnect
      @listen_task.stop
      @listen_task.wait

      @connection.close
      @client.close

      reset!
    end

    private

    def reset!
      @connected = false
      @response_queue = nil
      @client = nil
      @connection = nil
      @response_queue = nil
      @listen_task = nil
    end
  end
end
