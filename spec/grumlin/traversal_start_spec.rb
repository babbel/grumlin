# frozen_string_literal: true

RSpec.describe Grumlin::TraversalStart, gremlin_server: true do
  describe "#tx" do
    subject { g.tx }

    context "when traversal start is not already bound to a transaction" do
      context "when block is given" do
        context "when provider is :tinkergraph" do
          it "yields a sessionless TraversalStart" do
            expect { |b| g.tx(&b) }.to yield_with_args(described_class)

            g.tx do |gtx|
              expect(gtx.session_id).to be_nil
            end
          end
        end

        context "when provider is :neptune" do
          before do
            Grumlin.configure do |config|
              config.provider = :neptune
            end
          end

          it "yields a TraversalStart bound to a session and commits transaction" do
            expect_any_instance_of(Grumlin::Transaction).to receive(:commit) # rubocop:disable RSpec/AnyInstance

            expect { |b| g.tx(&b) }.to yield_with_args(described_class)
          end

          context "when Grumlin::Rollback is raised from the block" do
            it "silently rollbacks the transaction" do
              expect_any_instance_of(Grumlin::Transaction).to receive(:rollback) # rubocop:disable RSpec/AnyInstance
              expect do
                g.tx do |_gtx|
                  raise Grumlin::Rollback
                end
              end.not_to raise_error
            end
          end

          context "when other exception is raised" do
            it "rollbacks the transaction and reraises the error" do
              expect_any_instance_of(Grumlin::Transaction).to receive(:rollback) # rubocop:disable RSpec/AnyInstance
              expect do
                g.tx do |_gtx|
                  raise RuntimeError
                end
              end.to raise_error(RuntimeError)
            end
          end
        end
      end

      context "when block is not given" do
        context "when provider is :tinkergraph" do
          it "returns a dummy transaction" do
            expect(subject).to be_an_instance_of(Grumlin::DummyTransaction)
          end
        end

        context "when provider is :neptune" do
          before do
            Grumlin.configure do |config|
              config.provider = :neptune
            end
          end

          it "returns a transaction" do
            expect(subject).to be_an_instance_of(Grumlin::Transaction)
          end
        end
      end
    end

    context "when traversal start is already bound to a transaction" do
      subject { g.tx.begin.tx }

      before do
        Grumlin.configure do |config|
          config.provider = :neptune
        end
      end

      include_examples "raises an exception", Grumlin::TraversalStart::AlreadyBoundToTransactionError
    end
  end
end
