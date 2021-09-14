# frozen_string_literal: true

module Grumlin
  module P
    module P
      class Predicate < TypedValue
        def initialize(name, args)
          super("P", build_value(name, args))
        end

        private

        def build_value(name, args)
          type, args = cast_args(args)
          { predicate: name, value: { "@type": type, "@value": args } }
        end

        def cast_args(args)
          if args.count > 1
            ["g:List", args]
          else
            ["g:String", args[0]] # TODO: support other types
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
