# frozen_string_literal: true

module Grumlin
  class Transaction
    attr_reader :uuid

    def initialize(traversal_start_class, pool: Grumlin.default_pool)
      @pool = pool
      @traversal_start_class = traversal_start_class

      @uuid = SecureRandom.uuid
    end

    def begin
      @traversal_start_class.new(session_id: @uuid)
    end

    def commit
      client_write(%w[tx commit]) # TODO: use Action
    end

    def rollback
      client_write(%w[tx rollback]) # TODO: use Action
    end

    private

    def client_write(payload)
      @pool.acquire do |client|
        client.write(payload, session_id: @session_id)
      end
    end
  end
end
