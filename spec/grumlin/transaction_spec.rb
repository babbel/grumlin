# frozen_string_literal: true

RSpec.describe Grumlin::Transaction, gremlin_server: true do
  let(:tx) { g.tx }

  describe "defaults" do
    context "when provider is tinkergraph" do
      before do
        Grumlin.config.provider = :tinkergraph
      end

      it "has not assigned uuid" do
        expect(tx.uuid).to be_nil
      end
    end

    context "when provider is neptune" do
      before do
        Grumlin.config.provider = :neptune
      end

      it "has assigned uuid" do
        expect(tx.uuid).not_to be_nil
      end
    end
  end

  describe "#begin" do
    subject { tx.begin }

    context "when provider is tinkergraph" do
      before do
        Grumlin.config.provider = :tinkergraph
      end

      it "returns a TraversalStart without session_id" do
        expect(subject).to be_a(Grumlin::TraversalStart)
        expect(subject.session_id).to be_nil
      end
    end

    context "when provider is neptune" do
      before do
        Grumlin.config.provider = :neptune
      end

      it "returns a TraversalStart session_id" do
        expect(subject).to be_a(Grumlin::TraversalStart)
        expect(subject.session_id).not_to be_nil
      end
    end
  end

  xdescribe "#commit" do # rubocop:disable Lint/EmptyBlock, RSpec/EmptyExampleGroup
  end

  xdescribe "#rollback" do # rubocop:disable Lint/EmptyBlock, RSpec/EmptyExampleGroup
  end
end
