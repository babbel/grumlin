# frozen_string_literal: true

module Grumlin
  module Order
    class << self
      DESC = { "@type": "g:Order", "@value": "desc" }.freeze
      ASC = { "@type": "g:Order", "@value": "desc" }.freeze

      def asc
        ASC
      end

      def desc
        DESC
      end
    end
  end
end
