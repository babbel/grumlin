# frozen_string_literal: true

RSpec.describe Grumlin::Property do
  let(:property) { described_class.new(value) }
  let(:value) { { key: "property_name", value: "property_value" } }

  describe ".new" do
    subject { property }

    it "assigns key" do
      expect(subject.key).to eq("property_name")
    end

    it "assigns value" do
      expect(subject.value).to eq("property_value")
    end

    it "calls Typing.cast for value" do
      expect(Grumlin::Typing).to receive(:cast).with("property_value").and_call_original # rubocop:disable RSpec/MessageSpies
      subject
    end
  end

  describe ".inspect" do
    it "returns string representation of the property" do
      expect(property.inspect).to eq("p[property_name->property_value]")
    end
  end

  describe ".to_s" do
    it "returns string representation of the property" do
      expect(property.to_s).to eq("p[property_name->property_value]")
    end
  end
end
