# frozen_string_literal: true

RSpec.describe Grumlin::Step, gremlin_server: true do
  describe "chaining" do
    context "when using aliases" do
      it "builds a chain" do # rubocop:disable RSpec/MultipleExpectations
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
      it "builds a chain" do # rubocop:disable RSpec/MultipleExpectations
        g.addV.property(Grumlin::T.id, 1)
         .addV.property(Grumlin::T.id, 2)
         .addV.property(Grumlin::T.id, 3).iterate

        t = g.addE("follows").from(Grumlin::U.V(1)).to(Grumlin::U.V(2))
             .addE("follows").from(Grumlin::U.V(2)).to(Grumlin::U.V(3))
             .addE("follows").from(Grumlin::U.V(3)).to(Grumlin::U.V(1))
        t.iterate

        expect(g.V().count.toList).to eq([3])
        expect(g.E().count.toList).to eq([3])
      end
    end

    context "when using elementMap" do
      before do
        g.addV(:test_label).property(Grumlin::T.id, 1).property("foo1", "bar").property("foo3", 3)
         .addV(:test_label).property(Grumlin::T.id, 2).property("foo2", "bar")
         .addV(:test_label).property(Grumlin::T.id, 3).property("foo3", 3).iterate
      end

      it "returns a map" do
        expect(g.V().elementMap.toList).to eq([{ foo1: "bar", foo3: 3, id: 1, label: "test_label" },
                                               { foo2: "bar", id: 2, label: "test_label" },
                                               { foo3: 3, id: 3, label: "test_label" }])
      end
    end

    context "when using within" do
      before do
        g.addV(:test_label).property(Grumlin::T.id, 1)
         .addV(:test_label).property(Grumlin::T.id, 2)
         .addV(:test_label).property(Grumlin::T.id, 3).iterate
      end

      it "returns a list of nodes" do
        expect(g.V().has(Grumlin::T.id, Grumlin::P.within(1, 3)).toList).not_to be_empty
      end
    end
  end
end
