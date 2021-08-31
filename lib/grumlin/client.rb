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
      end

      def closed?
        !@client.connected?
      end

      def close
        @client.close
      end

      def write(*args)
        @client.write(*args)
      end
    end

    def initialize(url, parent: Async::Task.current, **client_options)
      @url = url
      @client_options = client_options
      @parent = parent
      reset!
    end

    def connect
      @transport = build_transport
      response_channel = @transport.connect
      @request_dispatcher = RequestDispatcher.new
      @parent.async do
        response_channel.each do |response|
          @request_dispatcher.add_response(response)
        end
      rescue StandardError
        close
      end
    end

    def close
      @transport&.close
      if @request_dispatcher&.requests&.any?
        raise ResourceLeakError, "Request list is not empty: #{@request_dispatcher.requests}"
      end

      reset!
    end

    def connected?
      @transport&.connected? || false
    end

    # TODO: support yielding
    def write(*args)
      raise NotConnectedError unless connected?

      request_id = SecureRandom.uuid
      request = to_query(request_id, args)
      channel = @request_dispatcher.add_request(request)
      @transport.write(request)

      begin
        channel.dequeue.flat_map { |item| Typing.cast(item) }
      rescue Async::Stop
        retry if @request_dispatcher.ongoing_request?(request_id)
        raise Grumlin::UnknownRequestStoppedError, "#{request_id} is not in the ongoing requests list"
      end
    end

    def inspect
      "<#{self.class} url=#{@url} connected=#{connected?}>"
    end

    alias to_s inspect

    private

    def to_query(request_id, message)
      {
        requestId: request_id,
        op: "bytecode",
        processor: "traversal",
        args: {
          gremlin: Typing.to_bytecode(Translator.to_bytecode_query(message)),
          aliases: { g: :g }
        }
      }
    end

    def reset!
      @request_dispatcher = nil
      @transport = nil
    end

    def build_transport
      Transport.new(@url, parent: @parent, **@client_options)
    end
  end
end
