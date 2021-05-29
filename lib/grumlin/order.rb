# frozen_string_literal: true

module Grumlin
  module Order
    class Order
      DESC = { "@type": "g:Order", "@value": "desc" }.freeze
      ASC = { "@type": "g:Order", "@value": "desc" }.freeze

      class << self
        def asc
          ASC
        end

        def desc
          DESC
        end
      end
    end

    # TODO: use metaprogramming
    class << self
      def asc
        Order.asc
      end

      def desc
        Order.desc
      end
    end
  end
end
