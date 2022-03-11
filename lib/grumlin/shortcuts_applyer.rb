# frozen_string_literal: true

module Grumlin
  class ShortcutsApplyer
    class << self
      def call(steps)
        new.call(steps)
      end
    end

    def call(steps)
      return steps unless steps.uses_shortcuts?

      shortcuts = steps.shortcuts

      configuration_steps = process_steps(steps.configuration_steps, shortcuts)
      regular_steps = process_steps(steps.steps, shortcuts)

      Steps.new(shortcuts).tap do |processed_steps|
        (configuration_steps + regular_steps).each do |step|
          processed_steps.add(step.name, step.arguments)
        end
      end
    end

    private

    def process_steps(steps, shortcuts) # rubocop:disable Metrics/AbcSize
      steps.each_with_object([]) do |step, result|
        arguments = step.arguments.map do |arg|
          arg.is_a?(Steps) ? ShortcutsApplyer.call(arg) : arg
        end

        if shortcuts.include?(step.name)
          t = TraversalStart.new(shortcuts)
          action = shortcuts[step.name].apply(t, *arguments)
          next if action.nil? || action == t # Shortcut did not add any steps

          new_steps = ShortcutsApplyer.call(Steps.from(action))
          result.concat(new_steps.configuration_steps)
          result.concat(new_steps.steps)
        else
          result << StepData.new(step.name, arguments)
        end
      end
    end
  end
end
