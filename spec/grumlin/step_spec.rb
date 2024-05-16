# frozen_string_literal: true

RSpec.describe Grumlin::Step do
  let(:step_class) { shortcuts.step_class }
  let(:step) { step_class.new(name, args:, params:) }
  let(:name) { :V }
  let(:args) { [] }
  let(:params) { {} }
  let(:shortcuts) { Grumlin::Shortcuts::Storage.empty }

  describe "chaining" do
    context "when no shortcuts are used" do
      it "chains" do
        configuration_step = step_class.new(:withSideEffect, args: [:a], params: { a: 1 })
        expect(configuration_step.previous_step).to be_nil
        expect(configuration_step).to be_an(step_class)
        expect(configuration_step.name).to eq(:withSideEffect)
        expect(configuration_step.args).to eq([:a])
        expect(configuration_step.params).to eq({ a: 1 })

        start_step = configuration_step.V
        expect(start_step).to be_an(step_class)
        expect(start_step.name).to eq(:V)
        expect(start_step.args).to be_empty
        expect(start_step.params).to be_empty

        regular_step = start_step.has(:property, :value)
        expect(regular_step).to be_an(step_class)
        expect(regular_step.name).to eq(:has)
        expect(regular_step.args).to eq([:property, :value])
        expect(regular_step.params).to be_empty

        expect(regular_step.previous_step).to equal(start_step)
        expect(regular_step.previous_step.previous_step).to equal(configuration_step)
      end
    end

    context "when shortcuts are used" do
      subject { step.foo(:arg1, :arg2, param1: 1, param2: 2) }

      let(:shortcuts) { Grumlin::Shortcuts::Storage[{ foo: Grumlin::Shortcut.new(:foo) { nil } }] }

      context "when shortcut is empty" do
        it "returns a Step" do
          expect(subject).to be_a(step_class)
        end

        it "assigns passes args and params to the new Step" do
          expect(subject.args).to eq([:arg1, :arg2])
          expect(subject.params).to eq({ param1: 1, param2: 2 })
        end

        it "assigns previous_step" do
          expect(subject.previous_step).to equal(step)
        end
      end
    end
  end

  describe "#step" do
    subject { step.step("step", :arg1, :arg2, param1: 1, param2: 2) }

    it "returns a Step" do
      expect(subject).to be_a(step_class)
    end

    it "assigns passes args and params to the new Step" do
      expect(subject.args).to eq([:arg1, :arg2])
      expect(subject.params).to eq({ param1: 1, param2: 2 })
    end

    it "assigns previous_step" do
      expect(subject.previous_step).to equal(step)
    end
  end

  describe "#configuration_step?" do
    subject { step.configuration_step? }

    context "when step is a configuration step" do
      let(:name) { "withSideEffect" }

      include_examples "returns true"
    end

    context "when step is not a configuration_step" do
      include_examples "returns false"
    end
  end

  describe "#start_step?" do
    subject { step.start_step? }

    context "when step a start step" do
      include_examples "returns true"
    end

    context "when step is not a configuration_step" do
      let(:name) { "withSideEffect" }

      include_examples "returns false"
    end
  end

  describe "#regular_step?" do
    subject { step.regular_step? }

    context "when step a regular step" do
      let(:name) { :has }

      include_examples "returns true"
    end

    context "when step is not a configuration_step" do
      let(:name) { "withSideEffect" }

      include_examples "returns false"
    end
  end

  describe "#supported_step?" do
    subject { step.supported_step? }

    context "when step is supported" do
      include_examples "returns true"
    end

    context "when step is not supported" do
      let(:name) { "some_step" }

      include_examples "returns false"
    end
  end

  describe "#shortcut" do
    subject { step.shortcut }

    context "when step is a shortcut" do
      let(:shortcuts) { Grumlin::Shortcuts::Storage[{ cut: Grumlin::Shortcut.new(:name) { nil } }] }
      let(:name) { :cut }

      include_examples "returns a", Grumlin::Shortcut
    end

    context "when step is no a shortcut" do
      include_examples "returns nil"
    end
  end

  describe "#==" do
    subject { step == other_step }

    context "when name, args, params and previous step are equal" do
      let(:step) { step_class.new(:V).has(:property, :value).where(step_class.new(:has, args: [:property, :value])) }
      let(:other_step) { step_class.new(:V).has(:property, :value).where(step_class.new(:has, args: [:property, :value])) }

      include_examples "returns true"
    end

    context "when something is not equal" do
      let(:step) { step_class.new(:V).has(:property, :value).where(step_class.new(:has, args: [:property, :value])) }
      let(:other_step) { step_class.new(:V).has(:property, :value).where(step_class.new(:V, args: [:id])) }

      include_examples "returns false"
    end
  end

  describe "#steps" do
    subject { step.steps }

    include_examples "returns a", Grumlin::Steps
  end
end
