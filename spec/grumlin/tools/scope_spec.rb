# frozen_string_literal: true

RSpec.describe Grumlin::Tools::Scope do
  describe "::SUPPORTED_STEPS" do
    it "is sorted" do
      expect(described_class::SUPPORTED_STEPS).to eq(described_class::SUPPORTED_STEPS.sort)
    end
  end
end
