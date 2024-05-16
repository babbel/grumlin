# frozen_string_literal: true

class Grumlin::ShortcutsApplyer
  class << self
    def call(steps)
      return steps if !steps.is_a?(Grumlin::Steps) || !steps.uses_shortcuts?

      shortcuts = steps.shortcuts

      steps = [
        *process_steps(steps.configuration_steps, shortcuts),
        *process_steps(steps.steps, shortcuts)
      ]

      Grumlin::Steps.new(shortcuts).tap do |processed_steps|
        steps.each do |step|
          processed_steps.add(step.name, args: step.args, params: step.params)
        end
      end
    end

    private

    def process_steps(steps, shortcuts) # rubocop:disable Metrics/AbcSize
      steps.each_with_object([]) do |step, result|
        args = step.args.map { |arg| call(arg) }

        shortcut = shortcuts[step.name]
        next result << Grumlin::StepData.new(step.name, args:, params: step.params) unless shortcut&.lazy?

        t = shortcuts.__
        step = shortcut.apply(t, *args, **step.params)
        next if step.nil? || step == t # Shortcut did not add any steps

        new_steps = call(Grumlin::Steps.from(step))
        result.concat(new_steps.configuration_steps, new_steps.steps)
      end
    end
  end
end
