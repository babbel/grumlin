# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include Grumlin::Tools
    end

    def __
      Grumlin::Tools::U
    end

    def g
      Grumlin::Traversal.new
    end
  end
end
