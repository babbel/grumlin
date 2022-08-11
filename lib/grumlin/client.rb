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

      def write(bytecode, session_id: nil)
        @client.write(bytecode, session_id: session_id)
      ensure
        @count += 1
      end

      def finalize_tx(action, session_id)
        @client.finalize_tx(action, session_id)
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
    def write(bytecode, session_id: nil)
      raise NotConnectedError unless connected?

      request = to_query(bytecode, session_id: session_id)
      submit_request(request)
    end

    def finalize_tx(action, session_id)
      raise NotConnectedError unless connected?
      raise ArgumentError, "session_id cannot be nil" if session_id.nil?

      request = finalize_tx_query(action, session_id)
      submit_request(request)
    end

    def inspect
      "<#{self.class} url=#{@url} connected=#{connected?}>"
    end

    def to_s
      inspect
    end

    private

    def submit_request(request)
      channel = @request_dispatcher.add_request(request)
      @transport.write(request)

      begin
        channel.dequeue.flat_map { |item| Typing.cast(item) }
      rescue Async::Stop, Async::TimeoutError
        close(check_requests: false)
        raise
      end
    end

    # This might be overridden in successors
    def build_transport
      Transport.new(@url, parent: @parent, **@client_options)
    end

    def to_query(bytecode, session_id:)
      {
        requestId: SecureRandom.uuid,
        op: :bytecode,
        processor: session_id ? :session : :traversal,
        args: {
          gremlin: {
            :@type => "g:Bytecode",
            :@value => bytecode.serialize
          },
          aliases: { g: :g },
          session: session_id
        }.compact
      }
    end

    def finalize_tx_query(action, session_id)
      {
        requestId: SecureRandom.uuid,
        op: :bytecode,
        processor: session_id ? :session : :traversal,
        args: {
          gremlin: {
            :@type => "g:Bytecode",
            :@value => { source: [[:tx, action]] }
          },
          aliases: { g: :g },
          session: session_id
        }.compact
      }
    end
  end
end
