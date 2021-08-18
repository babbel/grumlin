# frozen_string_literal: true

module Async
  # Channel is a wrapper around Async::Queue that provides
  # a protocol and handy tools for passing data, exceptions and closing
  class Channel
    def initialize
      @queue = Async::Queue.new
      @closed = false
    end

    # Methods for publishers
    def <<(data)
      raise "Cannot send to a closed channel" if @closed # TODO: use a proper exception

      @queue << [:data, data]
    end

    def exception(exception)
      raise "Cannot send to a closed channel" if @closed # TODO: use a proper exception

      @queue << [:exception, exception]
    end

    def close
      @queue << [:close]
      @closed = true
    end

    # Methods for a subscriber
    def dequeue
      each do |payload| # rubocop:disable Lint/UnreachableLoop this is intended
        return payload
      end
    end

    def each
      @queue.each do |type, payload|
        case type
        when :exception
          raise payload
        when :data
          yield(payload)
        when :close
          break
        end
      end
    end
  end
end
