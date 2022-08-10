# frozen_string_literal: true

RSpec.describe Grumlin::Features do
  describe ".for" do
    subject { described_class.for(provider_name) }

    context "when provider is neptune" do
      let(:provider_name) { :neptune }

      it "returns a features list" do
        expect(subject).to be_a(Grumlin::Features::NeptuneFeatures)
      end
    end

    context "when provider is tunkergraph" do
      let(:provider_name) { :tinkergraph }

      it "returns a features list" do
        expect(subject).to be_a(Grumlin::Features::TinkergraphFeatures)
      end
    end

    context "when provider is unknown" do
      let(:provider_name) { :unk }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
