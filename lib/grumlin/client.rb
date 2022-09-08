# frozen_string_literal: true

module Grumlin
  class Client
    class PoolResource < Async::Pool::Resource
      attr_reader :client

      def self.call
        config = Grumlin.config
        new(config.url, client_factory: config.client_factory, concurrency: config.client_concurrency)
      end

      def initialize(url, client_factory:, concurrency: 1, parent: Async::Task.current)
        super(concurrency)
        @client = client_factory.call(url, parent).tap(&:connect)
        @parent = parent
      end

      def closed?
        !@client.connected?
      end

      def close
        @client.close
      end

      def write(query)
        @client.write(query)
      ensure
        @count += 1
      end

      def viable?
        !closed?
      end

      def reusable?
        !closed?
      end
    end

    include Console

    # Client is not reusable. Once closed should be recreated.
    def initialize(url, parent: Async::Task.current, **client_options)
      @url = url
      @client_options = client_options
      @parent = parent
      @request_dispatcher = nil
      @transport = nil
    end

    def connect
      raise ClientClosedError if @closed

      @transport = build_transport
      response_channel = @transport.connect
      @request_dispatcher = RequestDispatcher.new
      @response_task = @parent.async do
        response_channel.each do |response|
          @request_dispatcher.add_response(response)
        end
      rescue Async::Stop, Async::TimeoutError, StandardError
        close(check_requests: false)
      end
      logger.debug(self, "Connected")
    end

    # Before calling close the user must ensure that:
    # 1) There are no ongoing requests
    # 2) There will be no new writes after
    def close(check_requests: true) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      return if @closed

      @closed = true

      @transport&.close
      @transport&.wait

      @response_task&.stop
      @response_task&.wait

      return if @request_dispatcher&.requests&.empty?

      @request_dispatcher.clear unless check_requests

      raise ResourceLeakError, "Request list is not empty: #{@request_dispatcher.requests}" if check_requests
    ensure
      logger.debug(self, "Closed")
    end

    def connected?
      @transport&.connected? || false
    end

    # TODO: support yielding
    def write(query)
      raise NotConnectedError unless connected?

      channel = @request_dispatcher.add_request(query)
      begin
        @transport.write(query)
        channel.dequeue
      rescue Async::Stop, Async::TimeoutError
        close(check_requests: false)
        raise
      end
    end

    def inspect
      "<#{self.class} url=#{@url} connected=#{connected?}>"
    end

    def to_s
      inspect
    end

    private

    # This might be overridden in successors
    def build_transport
      Transport.new(@url, parent: @parent, **@client_options)
    end
  end
end
