# frozen_string_literal: true

class Grumlin::TraversalStrategies::OptionsStrategy < Grumlin::TypedValue
  def initialize(value)
    super(type: "OptionsStrategy", value: value)
  end
end
