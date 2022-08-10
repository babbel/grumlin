# frozen_string_literal: true

RSpec.describe Grumlin::Config do
  let(:config) { described_class.new }

  describe "defaults" do
    it "assigns meaningful default values" do
      expect(subject.pool_size).to eq(10)
      expect(subject.client_concurrency).to eq(5)
      expect(subject.provider).to eq(:tinkergraph)
      expect(subject.client_factory).to be_a(Proc)
      expect(subject.client_factory.arity).to eq(2)
    end
  end

  describe ".validate!" do
    subject { config.validate! }

    context "when provider is known" do
      before do
        config.provider = :neptune
      end

      it "does not raise any errors" do
        expect { subject }.not_to raise_error
      end
    end

    context "when provider is unknown" do
      before do
        config.provider = :unk
      end

      include_examples "raises an exception", described_class::UnknownProviderError
    end
  end
end
