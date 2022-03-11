# frozen_string_literal: true

RSpec.describe Grumlin::StepData do
  let(:step_data) { described_class.new("step", %i[arg1 arg2]) }

  describe "#==" do
    subject { step_data == other_step_data }

    context "when name and args are equal" do
      let(:other_step_data) { described_class.new("step", %i[arg1 arg2]) }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "when names are equal, but arguments are not" do
      let(:other_step_data) { described_class.new("step", [:arg1]) }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "when araguments are equal, but names are not" do
      let(:other_step_data) { described_class.new("another_", %i[arg1 arg2]) }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end
end
