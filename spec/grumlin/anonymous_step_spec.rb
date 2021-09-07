# frozen_string_literal: true

RSpec.describe Grumlin::AnonymousStep do
  let(:g) { described_class.new("V") }

  describe "::SUPPORTED_STEPS" do
    it "is sorted" do
      expect(described_class::SUPPORTED_STEPS).to eq(described_class::SUPPORTED_STEPS.sort)
    end
  end

  describe "#inspect" do
    it "returns bytecode representation of the traversal" do
      t = g.addV.as("first")
           .addV.as("second")
           .addV.as("third")
           .addE("follows").from("first").to("second")
           .addE("follows").from("second").to("third")
           .addE("follows").from("third").to("first")
      expect(t.inspect).to eq('[["V"], ["addV"], ["as", "first"], ["addV"], ["as", "second"], ["addV"], ["as", "third"], ["addE", "follows"], ["from", "first"], ["to", "second"], ["addE", "follows"], ["from", "second"], ["to", "third"], ["addE", "follows"], ["from", "third"], ["to", "first"]]')
    end
  end

  describe "#bytecode" do
    it "returns a Bytecode instance" do
      t = g.addV
      expect(t.bytecode).to be_an(Grumlin::Bytecode)
    end
  end
end
