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

  describe "#to_bytecode" do
    xit "returns bytecode representation of the travesal" do
      t = g.addV.as("first")
           .addV.as("second")
           .addV.as("third")
           .addE("follows").from("first").to("second")
           .addE("follows").from("second").to("third")
           .addE("follows").from("third").to("first")
      expect(t.to_bytecode).to eq([["V"],
                                   ["addV"],
                                   ["as", "first"],
                                   ["addV"],
                                   ["as", "second"],
                                   ["addV"],
                                   ["as", "third"],
                                   ["addE", "follows"],
                                   ["from", "first"],
                                   ["to", "second"],
                                   ["addE", "follows"],
                                   ["from", "second"],
                                   ["to", "third"],
                                   ["addE", "follows"],
                                   ["from", "third"],
                                   ["to", "first"]])
    end
  end
end
