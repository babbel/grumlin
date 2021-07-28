# frozen_string_literal: true

module Grumlin
  class Client
    class PoolResource < Async::Pool::Resource
      attr_reader :client

      def initialize
        super(Grumlin.config.client_concurrency)

        @client = Grumlin::Client.new(Grumlin.config.url).tap(&:connect)
      end

      def close
        @client.disconnect
      end
    end

    def initialize(url, parent: Async::Task.current)
      @parent = parent
      @transport = Transport.new(url)
      reset!
    end

    def connect
      response_queue = @transport.connect
      @request_dispatcher = RequestDispatcher.new
      @parent.async do
        response_queue.each do |response|
          @request_dispatcher.add_response(response)
        end
      end
    end

    def disconnect
      @transport.disconnect
      reset!
    end

    # TODO: support yielding
    def write(*args) # rubocop:disable Metrics/MethodLength
      request_id = SecureRandom.uuid
      request = to_query(request_id, args)
      queue = @request_dispatcher.add_request(request)
      @transport.write(request)

      begin
        msg, response = queue.dequeue
        raise response if msg == :error

        return response.flat_map { |item| Typing.cast(item) } if msg == :result

        raise "ERROR"
      rescue Async::Stop
        retry if @request_dispatcher.ongoing_request?(request_id)
        raise UnknownRequestStopped, "#{request_id} is not in the ongoing requests list"
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
