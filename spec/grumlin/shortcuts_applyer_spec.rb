# frozen_string_literal: true

RSpec.describe Grumlin::ShortcutsApplyer do
  describe ".call" do
    subject { described_class.call(steps) }

    let(:steps) { action.steps }

    context "when steps does not use shortcuts" do
      let(:action) { Grumlin::Action.new(:V).hasLabel(:test).where(Grumlin::Action.new(:out).has(:property, :value)) }

      it "returns steps as is" do
        expect(subject).to eq(steps)
      end
    end

    context "when steps uses shortcuts" do
      let(:shortcuts) do
        {
          hasColor: Grumlin::Shortcut.new(:hasColor) { |color| has(:color, color) },
          hasShape: Grumlin::Shortcut.new(:hasShape) { |shape| has(:shape, shape) },
          hasShapeAndColor: Grumlin::Shortcut.new(:hasShapeAndColor) { |shape, color| hasShape(shape).hasColor(color) },
          addWeights: Grumlin::Shortcut.new(:addWeights) { withSideEffect(:weights, a: 1, b: 2) },
          preconfigure: Grumlin::Shortcut.new(:preconfigure) { addWeights },
          emptyShortcut: Grumlin::Shortcut.new(:preconfigure) { nil }
        }
      end

      context "when shortcuts are used in the main traversal" do
        let(:action) do
          Grumlin::Action.new(:V, shortcuts: shortcuts).hasColor(:red).hasShape(:triangle)
        end

        it "replaces shortcuts with actual steps" do
          expect(subject).to eq(
            Grumlin::Action.new(:V, shortcuts: shortcuts).has(:color, :red).has(:shape, :triangle).steps
          )
        end

        it "returns steps that doesn't use shortcuts" do
          expect(subject).not_to be_uses_shortcuts
        end
      end

      context "when shortcuts are used in anonymous traversals" do
        let(:action) do
          Grumlin::Action.new(:V, shortcuts: shortcuts)
                         .where(
                           Grumlin::Action.new(:hasColor, args: [:red], shortcuts: shortcuts)
                         )
                         .where(Grumlin::Action.new(:hasShape, args: [:triangle], shortcuts: shortcuts))
        end

        it "replaces shortcuts with actual steps" do
          expect(subject).to eq(
            Grumlin::Action.new(:V, shortcuts: shortcuts)
              .where(
                Grumlin::Action.new(:has, args: %i[color red], shortcuts: shortcuts)
              )
              .where(Grumlin::Action.new(:has, args: %i[shape triangle], shortcuts: shortcuts)).steps
          )
        end

        it "returns steps that doesn't use shortcuts" do
          expect(subject).not_to be_uses_shortcuts
        end
      end

      context "when shortcuts are used in another shortcuts" do
        let(:action) do
          Grumlin::Action.new(:V, shortcuts: shortcuts).hasShapeAndColor(:triangle, :red)
        end

        it "replaces shortcuts with actual steps" do
          expect(subject).to eq(
            Grumlin::Action.new(:V, shortcuts: shortcuts).has(:shape, :triangle).has(:color, :red).steps
          )
        end

        it "returns steps that doesn't use shortcuts" do
          expect(subject).not_to be_uses_shortcuts
        end
      end

      context "when shortcut is empty" do
        let(:action) do
          Grumlin::Action.new(:V, shortcuts: shortcuts).emptyShortcut
        end

        it "replaces shortcuts with nothing" do
          expect(subject).to eq(
            Grumlin::Action.new(:V, shortcuts: shortcuts).steps
          )
        end

        it "returns steps that doesn't use shortcuts" do
          expect(subject).not_to be_uses_shortcuts
        end
      end
    end
  end
end
