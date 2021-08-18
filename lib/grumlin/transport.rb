# frozen_string_literal: true

module Grumlin
  class Transport
    # A transport based on https://github.com/socketry/async
    # and https://github.com/socketry/async-websocket
    def initialize(url, parent: Async::Task.current)
      @endpoint = Async::HTTP::Endpoint.parse(url)
      @parent = parent
      @request_channel = Async::Channel.new
      @response_channel = Async::Channel.new
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
          @response_channel << data
        end
      rescue Async::Stop
        @response_channel.close
      rescue StandardError => e
        @response_channel.exception(e)
      end

      @request_task = @parent.async do
        @request_channel.each do |message|
          @connection.write(message)
          @connection.flush
        end
      end

      @connected = true

      @response_channel
    end

    def write(message)
      raise NotConnectedError unless connected?

      @request_channel << message
    end

    def close # rubocop:disable Metrics/MethodLength
      return unless connected?

      @request_channel.close
      @request_task.wait

      @response_task.stop
      @response_task.wait

      begin
        @connection.close
      rescue Errno::EPIPE
        nil
      end

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
