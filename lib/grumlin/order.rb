# frozen_string_literal: true

module Grumlin
  module Order
    module Order
      DESC = { "@type": "g:Order", "@value": "desc" }.freeze
      ASC = { "@type": "g:Order", "@value": "desc" }.freeze

      extend self # rubocop:disable Style/ModuleFunction

      def asc
        ASC
      end

      def desc
        DESC
      end
    end

    extend Order
  end
end
