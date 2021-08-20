# frozen_string_literal: true

module Grumlin
  module Sugar
    # TODO: how to use it in specs?
    HELPERS = [
      Grumlin::U,
      Grumlin::T,
      Grumlin::P,
      Grumlin::Pop,
      Grumlin::Order
    ].freeze

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def const_missing(name)
        helper = HELPERS.find { |h| h.name.split("::").last.to_sym == name }
        super if helper.nil?

        const_set(name, helper)
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
