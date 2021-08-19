# frozen_string_literal: true

module Grumlin
  class Client
    class PoolResource < self
      attr :concurrency, :count

      def self.call
        new(Grumlin.config.url, concurrency: Grumlin.config.client_concurrency).tap(&:connect)
      end

      def initialize(url, concurrency: 1, parent: Async::Task.current)
        super(url, parent: parent)
        @concurrency = concurrency
        @count = 0
      end

      def viable?
        connected?
      end

      def closed?
        connected?
      end

      def reusable?
        true
      end
    end

    def initialize(url, parent: Async::Task.current)
      @parent = parent
      @transport = Transport.new(url)
      reset!
    end

    def connect
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
      @transport.close
      raise ResourceLeakError, "Request list is not empty: #{requests}" if @request_dispatcher.requests.any?

      reset!
    end

    def connected?
      @transport.connected?
    end

    # TODO: support yielding
    def write(*args)
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
      "<#{self.class} url=#{@transport.url}>"
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
    end
  end
end
