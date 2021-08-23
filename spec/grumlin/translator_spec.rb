# frozen_string_literal: true

RSpec.describe Grumlin::Translator, gremlin_server: true do
  describe ".to_bytecode" do
    subject { described_class.to_bytecode(steps) }

    context "when there are no subtraversals" do
      let(:steps) do
        g.addE("follows").from("first").to("second").steps
      end

      it "returns bytecode" do
        expect(subject).to eq([["addE", "follows"], ["from", "first"], ["to", "second"]])
      end
    end

    context "when there are simple subtraversals" do
      let(:steps) do
        g.addE("follows").from(U.V(1)).to(U.V(2)).steps
      end

      it "returns bytecode" do
        expect(subject).to eq([["addE", "follows"], ["from", [["V", 1]]], ["to", [["V", 2]]]])
      end
    end

    context "when there are long subtraversals" do
      let(:steps) do
        g.V().hasLabel("continent").group.by("code").by(U.out.count).steps
      end

      it "returns bytecode" do
        expect(subject).to eq([["V"], %w[hasLabel continent], ["group"], %w[by code],
                               ["by", [["out"], ["count"]]]])
      end
    end
  end
end
