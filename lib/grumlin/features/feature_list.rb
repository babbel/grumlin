# frozen_string_literal: true

module Grumlin
  module Features
    class FeatureList
      def user_supplied_ids?
        raise(NotImplementedError) if @user_supplied_ids.nil?

        @user_supplied_ids
      end

      def supports_transactions?
        raise(NotImplementedError) if @supports_transactions.nil?

        @supports_transactions
      end
    end
  end
end
