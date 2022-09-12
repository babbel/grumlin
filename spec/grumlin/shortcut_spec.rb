# frozen_string_literal: true

RSpec.describe Grumlin::Shortcut do
  let(:shortcut) { described_class.new(:test_step, &block) }
  let(:name) { :test_step }
  let(:block) { proc {} }

  describe "#initialize" do
    it "assigns name and block" do
      expect(shortcut.name).to eq(:test_step)
      expect(shortcut.block).to eq(block)
    end
  end

  describe "#==" do
    subject { shortcut == another_shortcut }

    let(:another_shortcut) { described_class.new(another_name, &another_block) }

    context "when names and blocks are equal" do
      let(:another_name) { name }
      let(:another_block) { block }

      include_examples "returns true"
    end

    context "when names are different, but blocks are equal" do
      let(:another_name) { :another_test_step }
      let(:another_block) { block }

      include_examples "returns false"
    end

    context "when names are equal, but blocks are different" do
      let(:another_name) { name }
      let(:another_block) { proc {} }

      include_examples "returns false"
    end
  end

  describe "#apply" do
    subject { shortcut.apply(object, 1, 2, a: 1) }

    let(:block) { proc { |a, b, **params| foo(a, b, **params) } }
    let(:object) { double(Object, foo: true) } # rubocop:disable RSpec/VerifiedDoubles

    it "executes the block in the context of the passed object" do
      subject
      expect(object).to have_received(:foo).with(1, 2, a: 1)
    end
  end
end
