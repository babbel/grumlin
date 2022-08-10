# frozen_string_literal: true

module Grumlin
  module Features
    class TinkergraphFeatures < FeatureList
      def initialize
        super
        @user_supplied_ids = true
        @supports_transactions = false
      end
    end
  end
end
