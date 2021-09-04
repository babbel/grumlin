# frozen_string_literal: true

module Grumlin
  class Transport
    # A transport based on https://github.com/socketry/async
    # and https://github.com/socketry/async-websocket

    attr_reader :url

    # Transport is not reusable. Once closed should be recreated.
    def initialize(url, parent: Async::Task.current, **client_options)
      @url = url
      @parent = parent
      @client_options = client_options
      @request_channel = Async::Channel.new
      @response_channel = Async::Channel.new
    end

    def connected?
      !@connection.nil?
    end

    def connect # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      raise "ClientClosed" if @closed
      raise AlreadyConnectedError if connected?

      @connection = Async::WebSocket::Client.connect(Async::HTTP::Endpoint.parse(@url), **@client_options)

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
      rescue Async::Stop
        @response_channel.close
      rescue StandardError => e
        @response_channel.exception(e)
      end

      @response_channel
    end

    def write(message)
      raise NotConnectedError unless connected?

      @request_channel << message
    end

    def close
      @closed = true
      return unless connected?

      @request_channel.close
      @request_task.wait

      @response_task.stop
      @response_task.wait

      @response_channel.close

      begin
        @connection.close
      rescue Errno::EPIPE
        nil
      end
    end
  end
end
