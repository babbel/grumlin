# frozen_string_literal: true

module Grumlin
  module P
    module P
      class Predicate < TypedValue
        def initialize(name, args)
          super(build_value(name, args), type: "P")
        end

        private

        def build_value(name, args)
          type, args = cast_args(args)
          { predicate: name, value: TypedValue.new(args, type: type).to_bytecode }
        end

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
