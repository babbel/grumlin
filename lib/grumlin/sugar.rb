# frozen_string_literal: true

module Grumlin
  module Sugar
    HELPERS = [
      Grumlin::Tools::Order,
      Grumlin::Tools::P,
      Grumlin::Tools::Pop,
      Grumlin::Tools::T,
      Grumlin::Tools::U
    ].freeze

    def self.included(base)
      HELPERS.each do |helper|
        name = helper.name.split("::").last
        base.const_set(name, helper)
      end
    end

    def __
      Grumlin::Tools::U
    end

    def g
      Grumlin::Traversal.new
    end
  end
end
