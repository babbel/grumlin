# frozen_string_literal: true

module Grumlin
  class Transaction
    def initialize(traversal_start_class)
      @traversal_start_class = traversal_start_class
    end

    def begin; end

    def commit; end

    def rollback; end
  end
end
