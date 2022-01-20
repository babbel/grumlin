# frozen_string_literal: true

module Grumlin
  module Expressions
    module WithOptions
      WITH_OPTIONS = Grumlin.definitions.dig(:expressions, :with_options).freeze

      class << self
        WITH_OPTIONS.each do |k, v|
          define_method k do
            v
          end
        end
      end
    end
  end
end
