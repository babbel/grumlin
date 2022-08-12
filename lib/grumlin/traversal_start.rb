# frozen_string_literal: true

module Grumlin
  class TraversalStart < Steppable
    include WithExtension

    class TraversalError < Grumlin::Error; end
    class AlreadyBoundToTransactionError < TraversalError; end

    def tx
      raise AlreadyBoundToTransactionError if @session_id

      transaction = tx_class.new(self.class, pool: @pool)
      return transaction unless block_given?

      begin
        yield transaction.begin
      rescue Grumlin::Rollback
        transaction.rollback
      rescue StandardError
        transaction.rollback
        raise
      else
        transaction.commit
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
      Grumlin.features.supports_transactions? ? Transaction : DummyTransaction
    end
  end
end
