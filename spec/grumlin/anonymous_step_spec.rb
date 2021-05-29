# frozen_string_literal: true

RSpec.describe Grumlin::AnonymousStep do
  let(:g) { Grumlin::U.V() }

  describe "#inspect" do
    it "returns bytecode representation of the travesal" do
      t = g.addV.as("first")
           .addV.as("second")
           .addV.as("third")
           .addE("follows").from("first").to("second")
           .addE("follows").from("second").to("third")
           .addE("follows").from("third").to("first")
      expect(t.inspect).to eq('[["V"], ["addV"], ["as", "first"], ["addV"], ["as", "second"], ["addV"], ["as", "third"], ["addE", "follows"], ["from", "first"], ["to", "second"], ["addE", "follows"], ["from", "second"], ["to", "third"], ["addE", "follows"], ["from", "third"], ["to", "first"]]') # rubocop:disable Layout/LineLength
    end
  end

  describe "#to_bytecode" do
    it "returns bytecode representation of the travesal" do
      t = g.addV.as("first")
           .addV.as("second")
           .addV.as("third")
           .addE("follows").from("first").to("second")
           .addE("follows").from("second").to("third")
           .addE("follows").from("third").to("first")
      # rubocop:disable Style/WordArray
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
      # rubocop:enable Style/WordArray
    end
  end
end
