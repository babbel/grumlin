# frozen_string_literal: true

class Grumlin::Transaction
  attr_reader :session_id, :pool

  include Console

  COMMIT = Grumlin::Repository.new.g.step(:tx, :commit)
  ROLLBACK = Grumlin::Repository.new.g.step(:tx, :rollback)

  def initialize(traversal_start_class, pool:, middlewares:)
    @traversal_start_class = traversal_start_class
    @pool = pool
    @session_id = SecureRandom.uuid
    @middlewares = middlewares
  end

  def begin
    @traversal_start_class.new(session_id: @session_id, pool: @pool)
  end

  def commit
    finalize(COMMIT)
  end

  def rollback
    finalize(ROLLBACK)
  end

  private

  def finalize(step)
    @middlewares.call(traversal: step,
                      need_results: false,
                      session_id: @session_id,
                      pool: @pool)
  ensure
    @pool.close
  end
end
