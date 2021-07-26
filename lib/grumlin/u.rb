# frozen_string_literal: true

module Grumlin
  module U
    module U
      extend self # rubocop:disable Style/ModuleFunction

      %w[addV V has count out values unfold].each do |step|
        define_method step do |*args|
          AnonymousStep.new(step, *args)
        end
      end
    end

    # TODO: add alias __
    extend U
  end
end
