# frozen_string_literal: true

class Grumlin::TraversalStart < Grumlin::Steppable
  include Grumlin::WithExtension

  class TraversalError < Grumlin::Error; end
  class AlreadyBoundToTransactionError < TraversalError; end

  def tx
    raise AlreadyBoundToTransactionError if @session_id

    # Pool should have size of 1 when working with session
    pool = Async::Pool::Controller.new(Grumlin::Client::PoolResource, limit: 1)

    transaction = tx_class.new(self.class, pool:, middlewares: @middlewares)
    return transaction unless block_given?

    result = nil

    begin
      result = yield transaction.begin
    rescue Grumlin::Rollback
      transaction.rollback
      result
    rescue StandardError
      transaction.rollback
      raise
    else
      transaction.commit
      result
    end
  end

  def to_s(*)
    self.class.to_s
  end

  def inspect
    self.class.inspect
  end

  private

  def tx_class
    Grumlin.features.supports_transactions? ? Grumlin::Transaction : Grumlin::DummyTransaction
  end
end
