# frozen_string_literal: true

module Grumlin
  module Sugar
    HELPERS = [
      Grumlin::U,
      Grumlin::T,
      Grumlin::P,
      Grumlin::Pop,
      Grumlin::Order
    ].freeze

    def self.included(base)
      HELPERS.each do |helper|
        name = helper.name.split("::").last
        base.const_set(name, helper)
      end
    end

    def __
      Grumlin::U
    end

    def g
      Grumlin::Traversal.new
    end
  end
end
