# frozen_string_literal: true

RSpec.describe Grumlin::Bytecode do
  include_context Grumlin::Test::RSpec::GremlinContext

  let(:bytecode) { described_class.new(step) }

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

    context "when there are configuration steps" do
      let(:step) do
        g.withSideEffect("a", "value").V.hasLabel(:node)
         .has(T.id, "node_id")
      end

      it "returns string representation of the bytecode" do
        expect(subject).to eq('[["withSideEffect", "a", "value"]][["V"], ["hasLabel", :node], ["has", "<T.id>", "node_id"]]')
      end
    end

    context "when there are no configuration steps" do
      let(:step) do
        g.V().hasLabel(:node)
         .has(T.id, "node_id")
         .order.by(:property, Order.desc)
         .repeat(__.out(:connection))
         .emit
         .hasLabel(:node)
      end

      it "returns string representation of the bytecode" do
        expect(subject).to eq('[["V"], ["hasLabel", :node], ["has", "<T.id>", "node_id"], ["order"], ["by", :property, "<Order.desc>"], ["repeat", [["out", :connection]]], ["emit"], ["hasLabel", :node]]')
      end
    end
  end

  describe "#value" do
    subject { bytecode.value }

    let(:step) do
      g.withSideEffect("a", "value").V.hasLabel(:node)
       .has(T.id, "node_id")
    end

    context "when there are configuration steps" do
      it "returns serialized bytecode" do
        expect(subject).to eq({ source: [["withSideEffect", "a", "value"]], step: [["V"], ["hasLabel", :node], ["has", { :@type => "g:T", :@value => :id }, "node_id"]] })
      end
    end

    context "when there are no configuration steps" do
      let(:step) do
        g.V().hasLabel(:node)
         .has(T.id, "node_id")
         .order.by(:property, Order.desc)
         .repeat(__.out(:connection))
         .emit
         .hasLabel(:node)
      end

      it "returns serialized bytecode" do
        expect(subject).to eq({ step: [["V"], ["hasLabel", :node], ["has", { :@type => "g:T", :@value => :id }, "node_id"], ["order"], ["by", :property, { :@type => "g:Order", :@value => :desc }], ["repeat", { :@type => "g:Bytecode", :@value => { step: [["out", :connection]] } }], ["emit"], ["hasLabel", :node]] })
      end
    end
  end
end
