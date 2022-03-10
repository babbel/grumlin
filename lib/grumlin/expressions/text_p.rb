# frozen_string_literal: true

module Grumlin
  module Expressions
    class TextP < P
      class << self
        %i[containing endingWith notContaining notEndingWith notStartingWith startingWith].each do |predicate|
          define_method predicate do |*args|
            P::Predicate.new("TextP", predicate, value: args[0])
          end
        end
      end
    end
  end
end
