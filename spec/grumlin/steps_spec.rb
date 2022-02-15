# frozen_string_literal: true

RSpec.describe Grumlin::Steps do
  let(:chain) { described_class.new }

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
    subject { chain.add(action) }

    let(:action) { Grumlin::Action.new(name, args: args, shortcuts: shortcuts) }
    let(:args) { [] }
    let(:shortcuts) { {} }

    context "when there are no regular and configuration steps" do
      context "when adding non Action" do
        let(:action) { "string" }

        include_examples "raises an exception", ArgumentError
      end

      context "when adding a configuration step" do
        let(:name) { :withSideEffect }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a configuration step" do
          expect { subject }.to change { chain.configuration_steps.count }.by(1)
        end

        it "does not add steps" do
          expect { subject }.not_to change(chain, :steps)
        end
      end

      context "when adding a start step" do
        let(:name) { :V }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(chain, :configuration_steps)
        end
      end

      context "when adding a shortcut" do
        let(:name) { :shortcut }
        let(:shortcuts) { { shortcut: -> {} } }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(chain, :configuration_steps)
        end
      end

      context "when adding a regular step" do
        let(:name) { :has }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end
      end
    end

    context "when there is a configuration step" do
      before do
        chain.add(Grumlin::Action.new(:withSideEffect))
      end

      context "when adding a configuration step" do
        let(:name) { :withSideEffect }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a configuration step" do
          expect { subject }.to change { chain.configuration_steps.count }.by(1)
        end

        it "does not add steps" do
          expect { subject }.not_to change(chain, :steps)
        end
      end

      context "when adding a start step" do
        let(:name) { :V }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(chain, :configuration_steps)
        end
      end

      context "when adding a shortcut" do
        let(:name) { :shortcut }
        let(:shortcuts) { { shortcut: -> {} } }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(chain, :configuration_steps)
        end
      end

      context "when adding a regular step" do
        let(:name) { :has }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end
      end
    end

    context "when there is a configuration step and a start step" do
      before do
        chain.add(Grumlin::Action.new(:withSideEffect))
        chain.add(Grumlin::Action.new(:V))
      end

      context "when adding a configuration step" do
        let(:name) { :withSideEffect }

        include_examples "raises an exception", ArgumentError

        it "does not add steps" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(chain, :steps)
        end

        it "does not add configuration steps" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to change(chain, :configuration_steps)
        end
      end

      context "when adding a start step" do
        let(:name) { :V }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(chain, :configuration_steps)
        end
      end

      context "when adding a shortcut" do
        let(:name) { :shortcut }
        let(:shortcuts) { { shortcut: -> {} } }

        it "returns a StepData" do
          expect(subject).to be_a(Grumlin::StepData)
        end

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(chain, :configuration_steps)
        end
      end

      context "when adding a regular step" do
        let(:name) { :has }

        it "adds a step" do
          expect { subject }.to change { chain.steps.count }.by(1)
        end

        it "does not add configuration steps" do
          expect { subject }.not_to change(chain, :configuration_steps)
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
            expect { subject }.to change { chain.steps.count }.by(1)
          end

          it "does not add configuration steps" do
            expect { subject }.not_to change(chain, :configuration_steps)
          end
        end
      end
    end
  end
end
