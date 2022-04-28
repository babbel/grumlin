# frozen_string_literal: true

module Async
  # Channel is a wrapper around Async::Queue that provides
  # a protocol and handy tools for passing data, exceptions and closing.
  # It is designed to be used only with one publisher and one subscriber
  class Channel
    class ChannelError < StandardError; end

    class ChannelClosedError < ChannelError; end

    def initialize
      @queue = Async::Queue.new
      @closed = false
    end

    def closed?
      @closed
    end

    def open?
      !@closed
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
      return if closed?

      @queue << [:close]
      @closed = true
    end

    # TODO: cover me
    def close!
      return if closed?

      exception(ChannelClosedError.new("Channel was forcefully closed"))
      close
    end

    # Methods for a subscriber
    def dequeue
      each do |payload| # rubocop:disable Lint/UnreachableLoop this is intended
        return payload
      end
    end

    def each
      raise(ChannelClosedError, "Cannot receive from a closed channel") if closed?

      @queue.each do |type, payload|
        case type
        when :exception
          payload.set_backtrace(caller + (payload.backtrace || [])) # A hack to preserve full backtrace
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
