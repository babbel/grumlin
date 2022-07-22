# frozen_string_literal: true

module Grumlin
  module WithExtension
    def with(name, value)
      prev = self
      strategy = if is_a?(with_action_class)
                   prev = previous_step
                   TraversalStrategies::OptionsStrategy.new(args.first.value.merge(name => value))
                 else
                   TraversalStrategies::OptionsStrategy.new({ name => value })
                 end
      with_action_class.new(:withStrategies, args: [strategy], previous_step: prev)
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
