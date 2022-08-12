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

  describe "#commit" do
    subject { tx.commit }

    context "when provider is :tinkergraph" do
      it "does nothing" do
        expect_any_instance_of(Grumlin::Transport).not_to receive(:write) # rubocop:disable RSpec/AnyInstance, no easier way
        expect { subject }.not_to raise_error
      end
    end

    context "when provider is :neptune" do
      before do
        allow(SecureRandom).to receive(:uuid).and_return("529962d2-374b-4470-915f-cf452bead1be")
        Grumlin.config.provider = :neptune
      end

      it "submits commit step" do
        expect_any_instance_of(Grumlin::Transport).to receive(:write).with( # rubocop:disable RSpec/AnyInstance, RSpec/StubbedMock no easier way
          { args: { aliases: { g: :g },
                    gremlin: { :@type => "g:Bytecode", :@value => { source: [%i[tx commit]] } },
                    session: "529962d2-374b-4470-915f-cf452bead1be" },
            op: :bytecode,
            processor: :session,
            requestId: "529962d2-374b-4470-915f-cf452bead1be" }
        ).and_raise(Async::Stop)
        # we raise a RuntimeError because otherwise client will be stuck waiting for the commit result
        # which are not sent on tinkergraph as it does not support transactions
        begin
          subject
        rescue Async::Stop
          nil
        end
      end
    end
  end

  describe "#rollback" do
    subject { tx.rollback }

    context "when provider is :tinkergraph" do
      it "does nothing" do
        expect_any_instance_of(Grumlin::Transport).not_to receive(:write) # rubocop:disable RSpec/AnyInstance, no easier way
        expect { subject }.not_to raise_error
      end
    end

    context "when provider is :neptune" do
      before do
        allow(SecureRandom).to receive(:uuid).and_return("529962d2-374b-4470-915f-cf452bead1be")
        Grumlin.config.provider = :neptune
      end

      it "submits commit step" do
        expect_any_instance_of(Grumlin::Transport).to receive(:write).with( # rubocop:disable RSpec/AnyInstance, RSpec/StubbedMock no easier way
          { args: { aliases: { g: :g },
                    gremlin: { :@type => "g:Bytecode", :@value => { source: [%i[tx rollback]] } },
                    session: "529962d2-374b-4470-915f-cf452bead1be" },
            op: :bytecode,
            processor: :session,
            requestId: "529962d2-374b-4470-915f-cf452bead1be" }
        ).and_raise(Async::Stop)
        # we raise a RuntimeError because otherwise client will be stuck waiting for the commit result
        # which are not sent on tinkergraph as it does not support transactions
        begin
          subject
        rescue Async::Stop
          nil
        end
      end
    end
  end
end
