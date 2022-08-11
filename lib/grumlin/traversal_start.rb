# frozen_string_literal: true

module Grumlin
  class TraversalStart < Steppable
    include WithExtension

    class TraversalError < Grumlin::Error; end
    class AlreadyBoundToTransationError < TraversalError; end

    def tx
      raise AlreadyBoundToTransationError if @session_id

      transaction = Transaction.new(self.class, pool: @pool)
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
  end
end
