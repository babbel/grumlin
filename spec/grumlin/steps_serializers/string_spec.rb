# frozen_string_literal: true

RSpec.describe Grumlin::StepsSerializers::String do
  let(:serializer) { described_class.new(steps, apply_shortcuts: apply_shortcuts) }

  let(:shortcuts) do
    {
      hasColor: ->(color) { has(:color, color) },
      hasShape: ->(shape) { has(:shape, shape) },
      hasShapeAndColor: ->(shape, color) { hasShape(shape).hasColor(color) },
      addWeights: -> { withSideEffect(:weights, a: 1, b: 2) },
      preconfigure: -> { addWeights }
    }
  end

  describe "#serialize" do
    subject { serializer.serialize }

    let(:apply_shortcuts) { false }

    context "when apply_shortcuts is false" do
      context "when there are no anonymous traversals" do
        let(:steps) { Grumlin::Action.new(:V).has(:color, :white).has(:shape, :rectangle).steps }

        it "returns a string representation of steps" do
          expect(subject).to eq('g.V().has("color", "white").has("shape", "rectangle")')
        end

        context "when a shortcut is used" do
          let(:steps) { Grumlin::Action.new(:V,  shortcuts: shortcuts).hasColor(:red).steps }

          it "returns a string representation of steps" do
            expect(subject).to eq('g.V().hasColor("red")')
          end
        end
      end

      context "when there are anonymous traversals" do
        let(:steps) { Grumlin::Action.new(:V).where(Grumlin::Action.new(:has, args: %i[color white])).has(:shape, :rectangle).steps }

        it "returns a string representation of steps" do
          expect(subject).to eq('g.V().where(__.has("color", "white")).has("shape", "rectangle")')
        end

        context "when a shortcut is used" do
          let(:steps) { Grumlin::Action.new(:V,  shortcuts: shortcuts).hasColor(:red).steps }

          it "returns a string representation of steps" do
            expect(subject).to eq('g.V().hasColor("red")')
          end
        end
      end

      context "when Expressions are used" do
        let(:steps) { Grumlin::Action.new(:V).has(Grumlin::Expressions::T.id, "id").steps }

        it "returns a string representation of steps" do
          expect(subject).to eq('g.V().has(T.id, "id")')
        end
      end
    end

    context "when apply_shortcuts is true" do
      let(:apply_shortcuts) { true }

      context "when there are no anonymous traversals" do
        let(:steps) { Grumlin::Action.new(:V).has(:color, :white).has(:shape, :rectangle).steps }

        it "returns a string representation of steps" do
          expect(subject).to eq('g.V().has("color", "white").has("shape", "rectangle")')
        end

        context "when a shortcut is used" do
          let(:steps) { Grumlin::Action.new(:V,  shortcuts: shortcuts).hasColor(:red).steps }

          it "returns a string representation of steps" do
            expect(subject).to eq('g.V().has("color", "red")')
          end
        end
      end

      context "when there are anonymous traversals" do
        let(:steps) { Grumlin::Action.new(:V).where(Grumlin::Action.new(:has, args: %i[color white])).has(:shape, :rectangle).steps }

        it "returns a string representation of steps" do
          expect(subject).to eq('g.V().where(__.has("color", "white")).has("shape", "rectangle")')
        end

        context "when a shortcut is used" do
          let(:steps) { Grumlin::Action.new(:V,  shortcuts: shortcuts).hasColor(:red).steps }

          it "returns a string representation of steps" do
            expect(subject).to eq('g.V().has("color", "red")')
          end
        end
      end
    end
  end
end
