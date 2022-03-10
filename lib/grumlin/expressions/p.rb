# frozen_string_literal: true

module Grumlin
  module Expressions
    class P
      class Predicate
        attr_reader :klass, :name, :value, :type

        def initialize(klass, name, value:, type: nil)
          @klass = klass
          @name = name
          @value = value
          @type = type
        end

        def namespace
          @namespace ||= @klass.to_s.split("::").last
        end
      end

      class << self
        # TODO: support more predicates
        %i[eq neq].each do |predicate|
          define_method predicate do |*args|
            Predicate.new(self, predicate, value: args[0])
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
            Predicate.new(self, predicate, value: args, type: "List")
          end
        end
      end
    end
  end
end
