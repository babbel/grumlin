# frozen_string_literal: true

class Grumlin::Features::TinkergraphFeatures < Grumlin::Features::FeatureList
  def initialize
    super
    @user_supplied_ids = true
    @supports_transactions = false
  end
end
