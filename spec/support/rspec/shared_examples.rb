# frozen_string_literal: true

RSpec.shared_examples "raises an exception" do |exception, message|
  it "raises #{exception.name}" do
    expect { subject }.to raise_error(exception, message)
  end
end

RSpec.shared_examples "raises TypeError" do |message|
  include_examples "raises an exception", TypeError, message
end

RSpec.shared_examples "has sorted constant" do |constant_name|
  describe "::#{constant_name}" do
    it "is sorted" do
      value = described_class.const_get(constant_name)
      expect(value).to eq(value.sort)
    end

    it "does not have duplicates" do
      value = described_class.const_get(constant_name)
      expect(value).to eq(value.uniq)
    end
  end
end
