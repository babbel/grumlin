# frozen_string_literal: true

module Grumlin
  module Expressions
    module P
      class Predicate
        attr_reader :name, :value, :type

        def initialize(name, value:, type: nil)
          @name = name
          @value = value
          @type = type
        end
      end

      class << self
        # TODO: support more predicates
        %i[eq neq].each do |predicate|
          define_method predicate do |*args|
            Predicate.new(predicate, value: args[0])
          end
        end

        %i[within without].each do |predicate|
          define_method predicate do |*args|
            args = if args.count == 1 && args[0].is_a?(Array)
                     args[0]
                   elsif args.count == 1 && args[0].is_a?(Set)
                     args[0].to_a
                   else
                     args.to_a
                   end
            Predicate.new(predicate, value: args, type: "List")
          end
        end
      end
    end
  end
end
