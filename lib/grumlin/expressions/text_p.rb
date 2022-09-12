# frozen_string_literal: true

class Grumlin::Expressions::TextP < Grumlin::Expressions::P
  class << self
    [:containing, :endingWith, :notContaining, :notEndingWith, :notStartingWith, :startingWith].each do |predicate|
      define_method predicate do |*args|
        P::Predicate.new("TextP", predicate, value: args[0])
      end
    end
  end
end
