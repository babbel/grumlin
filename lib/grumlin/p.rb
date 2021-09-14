# frozen_string_literal: true

module Grumlin
  module P
    module P
      class Predicate < TypedValue
        def initialize(name, args)
          super(type: "P")
          @name = name
          @args = args
        end

        def value
          @value ||= begin
            type, args = cast_args(@args) # TODO: Refactor me!
            {
              predicate: @name,
              value: TypedValue.new(type: type, value: args).to_bytecode
            }
          end
        end

        private

        def cast_args(args)
          if args.count > 1
            ["List", args]
          else
            ["String", args[0]] # TODO: support other types
          end
        end
      end

      # TODO: support more predicates
      %w[neq within].each do |predicate|
        define_method predicate do |*args|
          Predicate.new(predicate, args)
        end
      end
    end

    extend P
  end
end
