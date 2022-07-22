# frozen_string_literal: true

module Grumlin
  module TraversalStrategies
    class OptionsStrategy < TypedValue
      def initialize(value)
        super(type: "OptionsStrategy", value: value)
      end
    end
  end
end
