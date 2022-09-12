# frozen_string_literal: true

class Grumlin::Transport
  # A transport based on https://github.com/socketry/async
  # and https://github.com/socketry/async-websocket

  include Console

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

  def connect
    raise ClientClosedError if @closed
    raise AlreadyConnectedError if connected?

    @connection = Async::WebSocket::Client.connect(Async::HTTP::Endpoint.parse(@url), **@client_options)
    logger.debug(self) { "Connected to #{@url}." }

    @response_task = @parent.async { run_response_task }

    @request_task = @parent.async { run_request_task }

    @response_channel
  end

  def write(message)
    raise NotConnectedError unless connected?

    @request_channel << message
  end

  def close
    return if @closed

    @closed = true

    @request_channel.close
    @response_channel.close

    begin
      @connection.close
    rescue StandardError
      nil
    end
    @connection = nil

    @request_task&.stop(true)
    @response_task&.stop(true)
  end

  def wait
    @request_task.wait
    @response_task.wait
  end

  private

  def run_response_task
    with_guard do
      loop do
        data = @connection.read
        @response_channel << data
      end
    end
  end

  def run_request_task
    with_guard do
      @request_channel.each do |message|
        @connection.write(message)
        @connection.flush
      end
    end
  end

  def with_guard
    yield
  rescue Async::Stop, Async::TimeoutError, StandardError => e
    logger.debug(self) { "Guard error, closing." }
    begin
      @response_channel.exception(e)
    rescue Async::Channel::ChannelClosedError
      nil
    end
    close
  end
end
