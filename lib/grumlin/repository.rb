# frozen_string_literal: true

module Grumlin
  module Repository
    module InstanceMethods
      def __
        with_shortcuts(Grumlin::Expressions::U)
      end

      def g
        with_shortcuts(Grumlin::Traversal.new)
      end
    end

    def self.extended(base)
      base.extend(Grumlin::Shortcuts)
      base.include(Grumlin::Expressions)
      base.include(InstanceMethods)

      base.shortcuts_from(Grumlin::Shortcuts::Properties)
    end
  end
end
