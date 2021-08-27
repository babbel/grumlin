# frozen_string_literal: true

RSpec.describe Grumlin::U do
  describe "::SUPPORTED_START_STEPS" do
    it "is sorted" do
      expect(described_class::SUPPORTED_START_STEPS).to eq(described_class::SUPPORTED_START_STEPS.sort)
    end
  end
end
