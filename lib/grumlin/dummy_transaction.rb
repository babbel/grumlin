# frozen_string_literal: true

module Grumlin
  class DummyTransaction < Transaction
    attr_reader :uuid

    include Console

    def initialize(traversal_start_class, middlewares:, pool: nil) # rubocop:disable Lint/MissingSuper, Lint/UnusedMethodArgument
      @traversal_start_class = traversal_start_class

      logger.info(self) do
        "#{Grumlin.config.provider} does not support transactions. commit and rollback are ignored, data will be saved"
      end
    end

    def commit
      nil
    end

    def rollback
      nil
    end
  end
end
