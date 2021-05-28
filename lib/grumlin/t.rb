# frozen_string_literal: true

module Grumlin
  module T
    class T
      T_ID = { :@type => "g:T", :@value => "id" }.freeze

      class << self
        def id
          T_ID
        end
      end
    end

    # TODO: use metaprogramming
    class << self
      def id
        T.id
      end
    end
  end
end
