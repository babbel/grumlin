# frozen_string_literal: true

class Grumlin::Middlewares::FindMutatingSteps < Grumlin::Middlewares::FindBlocklistedSteps
  MUTATING_STEPS = [:addV, :addE, :property, :drop].freeze

  def initialize(app)
    super(app, *MUTATING_STEPS)
  end
end
