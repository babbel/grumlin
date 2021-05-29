# frozen_string_literal: true

module Grumlin
  module T
    module T
      T_ID = { :@type => "g:T", :@value => "id" }.freeze

      extend self # rubocop:disable Style/ModuleFunction

      def id
        T_ID
      end
    end

    extend T
  end
end
