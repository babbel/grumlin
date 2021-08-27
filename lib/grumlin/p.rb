# frozen_string_literal: true

module Grumlin
  module P
    module P
      %w[within].each do |step|
        define_method step do |*args|
          { # TODO: replace with a TypedValue?
            "@type": "g:P",
            "@value": { predicate: "within", value: { "@type": "g:List", "@value": args } }
          }
        end
      end
    end

    extend P
  end
end
