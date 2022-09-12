# frozen_string_literal: true

class Grumlin::StepsSerializers::Serializer
  def initialize(steps, **params)
    @steps = steps
    @params = params
  end

  def serialize
    raise NotImplementedError
  end
end
