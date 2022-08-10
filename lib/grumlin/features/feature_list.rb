# frozen_string_literal: true

module Grumlin
  module Features
    class FeatureList
      def user_supplied_ids?
        raise NotImplementedError
      end

      def supports_transactions?
        raise NotImplementedError
      end
    end
  end
end
