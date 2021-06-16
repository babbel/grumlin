# frozen_string_literal: true

module Grumlin
  module T
    module T
      T_ID = { :@type => "g:T", :@value => "id" }.freeze
      T_LABEL = { :@type => "g:T", :@value => "label" }.freeze

      extend self # rubocop:disable Style/ModuleFunction

      def id
        T_ID
      end

      def label
        T_LABEL
      end
    end

    extend T
  end
end
