# frozen_string_literal: true

module Grumlin
  module U
    module U
      extend self # rubocop:disable Style/ModuleFunction

      def V(*args) # rubocop:disable Naming/MethodName
        AnonymousStep.new("V", *args)
      end
    end

    extend U
  end
end
