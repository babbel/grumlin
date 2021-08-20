# frozen_string_literal: true

module Grumlin
  module U
    class << self
      %w[addV V has count out values unfold].each do |step|
        define_method step do |*args|
          AnonymousStep.new(step, *args)
        end
      end
    end
  end
end
