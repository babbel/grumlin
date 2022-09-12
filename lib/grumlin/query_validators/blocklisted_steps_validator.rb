# frozen_string_literal: true

class Grumlin::QueryValidators::BlocklistedStepsValidator < Grumlin::QueryValidators::Validator
  def initialize(*names)
    super()
    @names = names.to_set
  end

  protected

  def validate(steps, errors)
    (steps.configuration_steps + steps.steps).each do |step|
      if @names.include?(step.name)
        errors[:blocklisted_steps] ||= []
        errors[:blocklisted_steps] << step.name
      end
      step.args.each do |arg|
        validate(arg, errors) if arg.is_a?(Grumlin::Steps)
      end
    end
  end
end
