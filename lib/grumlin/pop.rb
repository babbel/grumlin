# frozen_string_literal: true

module Grumlin
  module Pop
    module Pop
      extend self # rubocop:disable Style/ModuleFunction

      FIRST = { "@type": "g:Pop", "@value": "first" }.freeze
      LAST = { "@type": "g:Pop", "@value": "last" }.freeze
      ALL = { "@type": "g:Pop", "@value": "all" }.freeze
      MIXED = { "@type": "g:Pop", "@value": "mixed" }.freeze

      def first
        FIRST
      end

      def last
        LAST
      end

      def all
        ALL
      end

      def mixed
        MIXED
      end
    end

    extend Pop
  end
end
