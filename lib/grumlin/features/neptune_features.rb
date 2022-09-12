# frozen_string_literal: true

class Grumlin::Features::NeptuneFeatures < Grumlin::Features::FeatureList
  def initialize
    super
    @user_supplied_ids = true
    @supports_transactions = true
  end
end
