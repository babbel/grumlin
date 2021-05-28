# frozen_string_literal: true

module Grumlin
  module U
    class U
      class << self
        def V(id) # rubocop:disable Naming/MethodName
          { "@type": "g:Bytecode", "@value": { step: [["V", id]] } }
        end
      end
    end

    # TODO: use metaprogramming
    class << self
      def V(id) # rubocop:disable Naming/MethodName
        U.V(id)
      end
    end
  end
end
