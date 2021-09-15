# frozen_string_literal: true

RSpec.describe Grumlin::Bytecode do
  include_context Grumlin::Test::RSpec::GremlinContext

  let(:bytecode) { described_class.new(step) }
  let(:step) do
    g.V().hasLabel(:node)
     .has(T.id, "node_id")
     .order.by(:property, Order.desc)
     .repeat(__.out(:connection))
     .emit
     .hasLabel(:node)
  end

  describe described_class::NoneStep do
    let(:step) { described_class.new }

    describe "#to_bytecode" do
      it "returns none bytecode step" do
        expect(step.to_bytecode).to eq(["none"])
      end
    end
  end

  describe "::NONE_STEP" do
    it "stores an instance on NoneStep" do
      expect(described_class::NONE_STEP).to be_an_instance_of(described_class::NoneStep)
    end
  end

  describe "#inspect" do
    subject { bytecode.inspect }

    it "returns string representation of the bytecode" do
      expect(subject).to eq('[["V"], ["hasLabel", :node], ["has", "<T.id>", "node_id"], ["order"], ["by", :property, "<Order.desc>"], ["repeat", [["out", :connection]]], ["emit"], ["hasLabel", :node]]')
    end
  end
end
