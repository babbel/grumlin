# frozen_string_literal: true

module Grumlin::WithExtension
  def with(name, value)
    prev = self
    strategy = if is_a?(with_step_class)
                 prev = previous_step
                 Grumlin::TraversalStrategies::OptionsStrategy.new(args.first.value.merge(name => value))
               else
                 Grumlin::TraversalStrategies::OptionsStrategy.new({ name => value })
               end
    with_step_class.new(:withStrategies, args: [strategy], previous_step: prev)
  end

  private

  def with_step_class
    @with_step_class ||= Class.new(shortcuts.step_class) do
      include Grumlin::WithExtension

      def with_step_class
        self.class
      end
    end
  end
end
