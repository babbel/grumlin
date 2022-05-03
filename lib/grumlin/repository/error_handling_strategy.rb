# frozen_string_literal: true

module Grumlin
  module Repository
    class ErrorHandlingStrategy
      def initialize(mode: :retry, **params)
        @mode = mode
        @params = params
        @on_exceptions = params[:on]
      end

      def raise?
        @mode == :raise
      end

      def ignore?
        @mode == :ignore
      end

      def retry?
        @mode == :retry
      end

      def apply!(&block)
        return yield if raise?
        return ignore_errors!(&block) if ignore?

        retry_errors!(&block)
      end

      private

      def ignore_errors!
        yield
      rescue *@on_exceptions
        # ignore errors
      end

      def retry_errors!(&block)
        Retryable.retryable(**@params, &block)
      end
    end
  end
end
