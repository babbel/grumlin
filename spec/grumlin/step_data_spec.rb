# frozen_string_literal: true

RSpec.describe Grumlin::StepData do
  let(:step_data) { described_class.new("step", args: %i[arg1 arg2], params: { key: :value }) }

  describe "#==" do
    subject { step_data == other_step_data }

    context "when name, args and params are equal" do
      let(:other_step_data) { described_class.new("step", args: %i[arg1 arg2], params: { key: :value }) }

      include_examples "returns true"
    end

    context "when name and args are equal, but params are not" do
      let(:other_step_data) { described_class.new("step", args: %i[arg1 arg2], params: { another_key: :another_value }) }

      include_examples "returns false"
    end

    context "when names are equal, but arguments are not" do
      let(:other_step_data) { described_class.new("step", args: [:arg1]) }

      include_examples "returns false"
    end

    context "when araguments are equal, but names are not" do
      let(:other_step_data) { described_class.new("another_", args: %i[arg1 arg2]) }

      include_examples "returns false"
    end
  end
end
