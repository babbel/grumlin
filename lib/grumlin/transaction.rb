# frozen_string_literal: true

module Grumlin
  class Transaction
    attr_reader :uuid

    include Console

    def initialize(traversal_start_class, pool: Grumlin.default_pool)
      @traversal_start_class = traversal_start_class
      @pool = pool

      if supported?
        @uuid = SecureRandom.uuid
        return
      end

      logger.info(self) do
        "#{Grumlin.config.provider} does not support transactions. commit and rollback are ignored, data will be saved"
      end
    end

    def supported?
      Grumlin.features.supports_transactions?
    end

    def begin
      @traversal_start_class.new(session_id: @uuid)
    end

    def commit
      return unless supported?

      finalize(:commit)
    end

    def rollback
      return unless supported?

      finalize(:rollback)
    end

    private

    def finalize(action)
      @pool.acquire do |client|
        client.finalize_tx(action, @uuid)
      end
    end
  end
end
