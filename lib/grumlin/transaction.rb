# frozen_string_literal: true

module Grumlin
  class Transaction
    attr_reader :uuid

    include Console

    def initialize(traversal_start_class, pool: Grumlin.default_pool)
      @traversal_start_class = traversal_start_class
      @pool = pool

      @uuid = SecureRandom.uuid
    end

    def begin
      @traversal_start_class.new(session_id: @uuid)
    end

    def commit
      finalize(:commit)
    end

    def rollback
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
