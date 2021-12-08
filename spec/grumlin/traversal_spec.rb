# frozen_string_literal: true

RSpec.describe Grumlin::Traversal, gremlin_server: true do
  include_examples "has sorted constant", "SUPPORTED_STEPS"
  include_examples "has sorted constant", "CONFIGURATION_STEPS"

  describe "start steps" do
    describe "#V" do
      subject { g.V(*ids).toList }

      let(:ids) { [] }

      context "when the DB is empty" do
        context "with no arguments" do
          it "returns an empty array" do
            expect(subject).to eq([])
          end
        end

        context "with arguments" do
          let(:ids) { [1, 2, 3] }

          it "returns an empty array" do
            expect(subject).to eq([])
          end
        end
      end

      context "when the DB is not empty" do
        before do
          g.addV("test_vertex").property(T.id, 1)
           .addV("test_vertex").property(T.id, 2).iterate
        end

        context "with no arguments" do
          it "returns vertices" do
            expect(subject).to eq([build(:vertex, id: 1), build(:vertex, id: 2)])
          end
        end

        context "with arguments" do
          let(:ids) { [2] }

          it "returns vertices" do
            expect(subject).to eq([build(:vertex, id: 2)])
          end
        end
      end
    end
  end

  describe "configuration steps" do
    describe "#withSideEffects" do
      subject { g.withSideEffect("test", "value") }

      before do
        g.addV("test_vertex").iterate
      end

      it "returns a Traversal with configuration step" do
        expect(subject).to be_an_instance_of(described_class)
        expect(subject.configuration_steps).not_to be_empty
        expect(subject.configuration_steps.first.name).to eq(:withSideEffect)
      end

      context "when executed" do
        it "properly sends configuration steps to the server" do
          expect(subject.V.select("test").next).to eq("value")
        end
      end
    end
  end
end
