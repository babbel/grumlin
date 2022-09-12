# frozen_string_literal: true

class Grumlin::QueryValidators::Validator
  class ValidationError < Grumlin::Error
    attr_reader :errors, :steps

    def initialize(steps, errors)
      super("Query is invalid: #{errors}")
      @steps = steps
      @errors = errors
    end
  end

  # steps is an instance of `Steps` after shortcuts applied
  def validate!(steps)
    return unless (err = errors(steps)).any?

    raise ValidationError.new(steps, err)
  end

  def valid?(steps)
    errors(steps).empty?
  end

  protected

  def errors(steps)
    {}.tap do |errors|
      validate(steps, errors)
    end
  end

  def validate(steps, errors)
    raise NotImplementedError
  end
end
