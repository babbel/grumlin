# frozen_string_literal: true

module Grumlin
  class Transaction
    attr_reader :session_id

    include Console

    COMMIT = Grumlin::Repository.new.g.step(:tx, :commit).bytecode
    ROLLBACK = Grumlin::Repository.new.g.step(:tx, :rollback).bytecode

    def initialize(traversal_start_class, pool:)
      @traversal_start_class = traversal_start_class
      @pool = pool

      @session_id = SecureRandom.uuid
    end

    def begin
      @traversal_start_class.new(session_id: @session_id)
    end

    def commit
      finalize(COMMIT)
    end

    def rollback
      finalize(ROLLBACK)
    end

    private

    def finalize(action)
      @pool.acquire do |client|
        client.write(action, session_id: @session_id)
      end
    end
  end
end
