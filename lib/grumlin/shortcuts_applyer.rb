# frozen_string_literal: true

module Grumlin
  class ShortcutsApplyer
    class << self
      def call(steps)
        return steps unless steps.uses_shortcuts?

        shortcuts = steps.shortcuts

        configuration_steps = process_steps(steps.configuration_steps, shortcuts)
        regular_steps = process_steps(steps.steps, shortcuts)

        Steps.new(shortcuts).tap do |processed_steps|
          (configuration_steps + regular_steps).each do |step|
            processed_steps.add(step.name, args: step.args, params: step.params)
          end
        end
      end

      private

      def process_steps(steps, shortcuts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        steps.each_with_object([]) do |step, result|
          args = step.args.map do |arg|
            arg.is_a?(Steps) ? ShortcutsApplyer.call(arg) : arg
          end

          if (shortcut = shortcuts[step.name])&.lazy?
            t = shortcuts.__
            action = shortcut.apply(t, *args, **step.params)
            next if action.nil? || action == t # Shortcut did not add any steps

            new_steps = ShortcutsApplyer.call(Steps.from(action))
            result.concat(new_steps.configuration_steps)
            result.concat(new_steps.steps)
          else
            result << StepData.new(step.name, args: args, params: step.params)
          end
        end
      end
    end
  end
end
