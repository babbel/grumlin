# frozen_string_literal: true

RSpec.describe Grumlin::DummyTransaction, :gremlin_server do
  let(:tx) { g.tx }

  describe "defaults" do
    it "has not assigned session_id" do
      expect(tx.session_id).to be_nil
    end
  end

  describe "#begin" do
    subject { tx.begin }

    include_examples "returns a", Grumlin::TraversalStart

    it "returns a TraversalStart without session_id" do
      expect(subject.session_id).to be_nil
    end
  end

  describe "#commit" do
    subject { tx.commit }

    it "does nothing" do
      expect_any_instance_of(Grumlin::Transport).not_to receive(:write) # rubocop:disable RSpec/AnyInstance, no easier way
      expect { subject }.not_to raise_error
    end
  end

  describe "#rollback" do
    subject { tx.rollback }

    it "does nothing" do
      expect_any_instance_of(Grumlin::Transport).not_to receive(:write) # rubocop:disable RSpec/AnyInstance, no easier way
      expect { subject }.not_to raise_error
    end
  end
end
