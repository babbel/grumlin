# frozen_string_literal: true

module Grumlin
  class TraversalStart < Steppable
    def to_s(*)
      self.class.to_s
    end

    def inspect
      self.class.inspect
    end
  end
end
