# frozen_string_literal: true

RSpec.shared_examples "raises an exception" do |exception, message|
  it "raises #{exception.name}" do
    expect { subject }.to raise_error(exception, message)
  end
end

RSpec.shared_examples "raises TypeError" do |message|
  include_examples "raises an exception", TypeError, message
end

RSpec.shared_examples "SUPPORTED_STEPS" do
  describe "::SUPPORTED_STEPS" do
    it "is sorted" do
      expect(described_class::SUPPORTED_STEPS).to eq(described_class::SUPPORTED_STEPS.sort)
    end

    it "does not have duplicates" do
      expect(described_class::SUPPORTED_STEPS).to eq(described_class::SUPPORTED_STEPS.uniq)
    end
  end
end
