# frozen_string_literal: true

module Grumlin
  module Expressions
    module P
      class << self
        class Predicate < TypedValue
          def initialize(name, args:, arg_type: nil)
            super(type: "P")
            @name = name
            @args = args
            @arg_type = arg_type
          end

          def value
            @value ||= {
              predicate: @name,
              value: TypedValue.new(type: @arg_type, value: @args).to_bytecode
            }
          end
        end

        # TODO: support more predicates
        %i[eq neq].each do |predicate|
          define_method predicate do |*args|
            Predicate.new(predicate, args: args[0])
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
            Predicate.new(predicate, args: args, arg_type: "List")
          end
        end
      end
    end
  end
end
