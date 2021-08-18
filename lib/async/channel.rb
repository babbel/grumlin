# frozen_string_literal: true

module Async
  # Channel is a wrapper around Async::Queue that provides
  # a protocol and handy tools for passing data, exceptions and closing.
  # It is designed to be used with only one publisher and one subscriber
  class Channel
    class ChannelClosedError < StandardError; end

    def initialize
      @queue = Async::Queue.new
      @closed = false
    end

    def closed?
      @closed
    end

    # Methods for a publisher
    def <<(payload)
      raise(ChannelClosedError, "Cannot send to a closed channel") if @closed

      @queue << [:payload, payload]
    end

    def exception(exception)
      raise(ChannelClosedError, "Cannot send to a closed channel") if closed?

      @queue << [:exception, exception]
    end

    def close
      raise(ChannelClosedError, "Cannot close a closed channel") if closed?

      @queue << [:close]
      @closed = true
    end

    # Methods for a subscriber
    def dequeue
      each do |payload| # rubocop:disable Lint/UnreachableLoop this is intended
        return payload
      end
    end

    def each # rubocop:disable Metrics/MethodLength
      raise(ChannelClosedError, "Cannot receive from a closed channel") if closed?

      @queue.each do |type, payload|
        case type
        when :exception
          raise payload
        when :payload
          yield payload
        when :close
          break
        end
      end
    end
  end
end
