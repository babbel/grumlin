# frozen_string_literal: true

RSpec.describe Grumlin::Step, gremlin_server: true do
  xdescribe "#inspect" do
    it "returns bytecode representation of the traversal" do
      t = g.addV.as("first")
           .addV.as("second")
           .addV.as("third")
           .addE("follows").from("first").to("second")
           .addE("follows").from("second").to("third")
           .addE("follows").from("third").to("first")
      expect(t.inspect).to eq('[["addV"], ["as", "first"], ["addV"], ["as", "second"], ["addV"], ["as", "third"], ["addE", "follows"], ["from", "first"], ["to", "second"], ["addE", "follows"], ["from", "second"], ["to", "third"], ["addE", "follows"], ["from", "third"], ["to", "first"]]')
    end
  end

  describe "#bytecode" do
    it "returns a Bytecode instance" do
      t = g.addV
      expect(t.bytecode).to be_an(Grumlin::Bytecode)
    end
  end

  describe "chaining" do
    context "when using aliases" do
      it "builds a chain" do
        g.addV.as("first")
         .addV.as("second")
         .addV.as("third")
         .addE("follows").from("first").to("second")
         .addE("follows").from("second").to("third")
         .addE("follows").from("third").to("first").iterate

        expect(g.V().count.toList).to eq([3])
        expect(g.E().count.toList).to eq([3])
      end
    end

    context "when using anonymous queries" do
      it "builds a chain" do
        g.addV.property(T.id, 1)
         .addV.property(T.id, 2)
         .addV.property(T.id, 3).iterate

        t = g.addE("follows").from(__.V(1)).to(__.V(2))
             .addE("follows").from(__.V(2)).to(__.V(3))
             .addE("follows").from(__.V(3)).to(__.V(1))
        t.iterate

        expect(g.V().count.toList).to eq([3])
        expect(g.E().count.toList).to eq([3])
      end
    end

    context "when using elementMap" do
      before do
        g.addV(:test_label).property(T.id, 1).property("foo1", "bar").property("foo3", 3)
         .addV(:test_label).property(T.id, 2).property("foo2", "bar")
         .addV(:test_label).property(T.id, 3).property("foo3", 3).iterate
      end

      it "returns a map" do
        expect(g.V().elementMap.toList).to eq([{ foo1: "bar", foo3: 3, id: 1, label: "test_label" },
                                               { foo2: "bar", id: 2, label: "test_label" },
                                               { foo3: 3, id: 3, label: "test_label" }])
      end
    end

    context "when using P.within" do
      before do
        g.addV(:test_label).property(T.id, 1)
         .addV(:test_label).property(T.id, 2)
         .addV(:test_label).property(T.id, 3).iterate
      end

      it "returns a list of nodes" do
        expect(g.V().has(T.id, P.within(1, 3)).toList).not_to be_empty
      end
    end

    context "when using P.neq" do
      before do
        g.addV(:test_label).property(T.id, 1)
         .addV(:test_label).property(T.id, 2)
         .addV(:test_label).property(T.id, 3).iterate
      end

      it "returns a list of nodes" do
        expect(g.V().has(T.id, P.neq(3)).toList.length).to eq(2)
      end
    end
  end
end
