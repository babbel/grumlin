# frozen_string_literal: true

module Grumlin
  class TraversalStart < Steppable
    include WithExtension

    class TraversalError < Grumlin::Error; end

    class AlreadyBoundToTransationError < TraversalError; end

    def tx
      raise AlreadyBoundToTransationError if @client

      Transaction.new(self.class)
    end

    def to_s(*)
      self.class.to_s
    end

    def inspect
      self.class.inspect
    end
  end
end
