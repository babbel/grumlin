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

    def connect # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @client = Async::WebSocket::Client.open(@endpoint)
      @connection = @client.connect(@endpoint.authority, @endpoint.path)
      @request_queue = Async::Queue.new
      @response_queue = Async::Queue.new

      @response_task = @task.async do
        loop do
          data = @connection.read
          @response_queue << data
        end
      rescue Async::Stop
        @response_queue << nil
      end

      @request_task = @task.async do
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

    def disconnect
      @request_queue << nil
      @request_task.wait

      @response_task.stop
      @response_task.wait

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
      @request_queue = nil
      @response_queue = nil
      @response_task = nil
      @request_task = nil
    end
  end
end
