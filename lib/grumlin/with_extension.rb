# frozen_string_literal: true

module Grumlin
  module WithExtension
    def with(name, value)
      with_action_class.new(:withStrategies, args: [TraversalStrategies::OptionsStrategy.new({ name => value })],
                                             previous_step: self)
    end

    private

    def with_action_class
      @with_action_class ||= Class.new(shortcuts.action_class) do
        include WithExtension

        def with_action_class
          self.class
        end
      end
    end
  end
end
