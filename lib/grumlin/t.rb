# frozen_string_literal: true

module Grumlin
  module T
    class << self
      T_ID = { "@type": "g:T", "@value": "id" }.freeze # TODO: replace with a class?
      T_LABEL = { "@type": "g:T", "@value": "label" }.freeze # TODO: replace with a class?

      def id
        T_ID
      end

      def label
        T_LABEL
      end
    end
  end
end
