# frozen_string_literal: true

module Grumlin
  module Features
    class NeptuneFeatures < FeatureList
      def initialize
        super
        @user_supplied_ids = true
        @supports_transactions = true
      end
    end
  end
end
