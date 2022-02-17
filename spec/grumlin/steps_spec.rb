# frozen_string_literal: true

RSpec.describe Grumlin::Steps do
  let(:steps) { described_class.new(shortcuts) }

  describe ".from" do
    subject { described_class.from(action) }

    let(:action) do
      Grumlin::Action.new(:withSideEffect, args: [:a], params: { b: 1 })
                     .V.has(:property, :value).where(Grumlin::Action.new(:out, args: :name))
    end

    it "returns a Steps" do
      expect(subject).to be_an(described_class)
    end
  end

  describe "#add" do
    subject { steps.add(name, args) }

    let(:args) { [] }
    let(:shortcuts) { {} }

    context "when there are no regular and configuration steps" do
      context "when adding a configuration step" do
        let(:name) { :withSideEffect }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a configuration step" do
          expect { subject }.to change { steps.configuration_steps.count }.by(1)
        end

        it "does not add steps" do
          expect { subject }.not_to change(steps, :steps)
        end
      end

      context "when adding a start step" do
        let(:name) { :V }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(steps, :configuration_steps)
        end
      end

      context "when adding a shortcut" do
        let(:name) { :shortcut }
        let(:shortcuts) { { shortcut: -> {} } }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(steps, :configuration_steps)
        end
      end

      context "when adding a regular step" do
        let(:name) { :has }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end
      end
    end

    context "when there is a configuration step" do
      before do
        steps.add(:withSideEffect, [])
      end

      context "when adding a configuration step" do
        let(:name) { :withSideEffect }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a configuration step" do
          expect { subject }.to change { steps.configuration_steps.count }.by(1)
        end

        it "does not add steps" do
          expect { subject }.not_to change(steps, :steps)
        end
      end

      context "when adding a start step" do
        let(:name) { :V }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(steps, :configuration_steps)
        end
      end

      context "when adding a shortcut" do
        let(:name) { :shortcut }
        let(:shortcuts) { { shortcut: -> {} } }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(steps, :configuration_steps)
        end
      end

      context "when adding a regular step" do
        let(:name) { :has }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end
      end
    end

    context "when there is a configuration step and a start step" do
      before do
        steps.add(:withSideEffect, [])
        steps.add(:V, [])
      end

      context "when adding a configuration step" do
        let(:name) { :withSideEffect }

        include_examples "raises an exception", ArgumentError

        it "does not add steps" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(steps, :steps)
        end

        it "does not add configuration steps" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(steps, :configuration_steps)
        end
      end

      context "when adding a start step" do
        let(:name) { :V }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(steps, :configuration_steps)
        end
      end

      context "when adding a shortcut" do
        let(:name) { :shortcut }
        let(:shortcuts) { { shortcut: -> {} } }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(steps, :configuration_steps)
        end
      end

      context "when adding a regular step" do
        let(:name) { :has }

        it "adds a step" do
          expect { subject }.to change { steps.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(steps, :configuration_steps)
        end

        context "with actions in arguments" do
          let(:name) { :where }
          let(:args) { [Grumlin::Action.new(:has, args: %i[property value])] }

          it "returns a StepData" do
            expect(subject).to be_a(Grumlin::StepData)
          end

          it "returns a step with casted arguments" do
            expect(subject.arguments[0]).to be_a(described_class)
          end

          it "adds a step" do
            expect { subject }.to change { steps.steps.count }.by(1)
          end

          it "does not add configuration steps" do
            expect { subject }.not_to change(steps, :configuration_steps)
          end
        end
      end
    end
  end

  describe "#uses_shortcuts?" do
    subject { steps.uses_shortcuts? }

    let(:shortcuts) do
      {
        hasColor: ->(color) { has(:color, color) },
        hasShape: ->(shape) { has(:shape, shape) },
        hasShapeAndColor: ->(shape, color) { hasShape(shape).hasColor(color) },
        addWeights: -> { withSideEffect(:weights, a: 1, b: 2) },
        preconfigure: -> { addWeights }
      }
    end

    context "when shortcuts are not used" do
      before do
        steps.add(:V, [])
        steps.add(:has, %i[property value])
      end

      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "when a shortcut is used in the main traversal" do
      before do
        steps.add(:V, [])
        steps.add(:hasColor, [:red])
      end

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "when when a shortcut is used in an anonymous traversal" do
      before do
        steps.add(:V, [])
        steps.add(:where, [Grumlin::Action.new(:hasColor, args: [:red], shortcuts: shortcuts)])
      end

      it "returns true" do
        expect(subject).to be_truthy
      end
    end
  end
end
