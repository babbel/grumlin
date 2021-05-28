# frozen_string_literal: true

module Grumlin
  module U
    class U
      class << self
        def V(*args) # rubocop:disable Naming/MethodName
          AnonymousStep.new("V", *args)
        end
      end
    end

    # TODO: use metaprogramming
    class << self
      def V(*args) # rubocop:disable Naming/MethodName
        U.V(*args)
      end
    end
  end
end
