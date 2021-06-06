# frozen_string_literal: true

RSpec.describe Grumlin::Translator do
  let(:g) { Grumlin::Traversal.new(nil) }

  describe ".to_bytecode" do
    subject { described_class.to_bytecode(steps) }

    context "when there are no subtraversals" do
      let(:steps) do
        g.addE("follows").from("first").to("second").steps
      end

      it "returns bytecode" do
        expect(subject).to eq([["addE", "follows"], ["from", "first"], ["to", "second"]]) # rubocop:disable Style/WordArray
      end
    end

    context "when there are subtraversals" do
      let(:steps) do
        g.addE("follows").from(Grumlin::U.V(1)).to(Grumlin::U.V(2)).steps
      end

      it "returns bytecode" do
        expect(subject).to eq([["addE", "follows"], ["from", [["V", 1]]], ["to", [["V", 2]]]])  # rubocop:disable Style/WordArray
      end
    end
  end
end
