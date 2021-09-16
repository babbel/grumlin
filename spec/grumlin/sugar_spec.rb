# frozen_string_literal: true

RSpec.describe Grumlin::Sugar do
  describe "::HELPERS" do
    it "is sorted" do
      expect(described_class::HELPERS.map(&:to_s).sort).to eq(described_class::HELPERS.map(&:to_s))
    end
  end
end
