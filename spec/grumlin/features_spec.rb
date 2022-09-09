# frozen_string_literal: true

RSpec.describe Grumlin::Features do
  describe ".for" do
    subject { described_class.for(provider_name) }

    context "when provider is neptune" do
      let(:provider_name) { :neptune }

      include_examples "returns a", Grumlin::Features::NeptuneFeatures
    end

    context "when provider is tinkergraph" do
      let(:provider_name) { :tinkergraph }

      include_examples "returns a", Grumlin::Features::TinkergraphFeatures
    end

    context "when provider is unknown" do
      let(:provider_name) { :unk }

      include_examples "returns nil"
    end
  end
end
