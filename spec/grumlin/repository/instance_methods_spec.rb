# frozen_string_literal: true

RSpec.describe Grumlin::Repository::InstanceMethods, gremlin_server: true do
  let(:repository_class) do
    Class.new do
      extend Grumlin::Repository

      shortcut :shortcut do
        property(:shortcut, true)
      end
    end
  end
  let(:repository) { repository_class.new }

  describe "#__" do
    it "returns TraversalStart" do
      expect(repository.__).to be_an(Grumlin::TraversalStart)
    end
  end

  describe "#g" do
    it "returns TraversalStart" do
      expect(repository.g).to be_an(Grumlin::TraversalStart)
    end
  end

  describe "#drop_vertex" do
    subject { repository.drop_vertex(id) }

    before do
      g.addV(:test).property(T.id, 123).iterate
    end

    context "when vertex exists" do
      let(:id) { 123 }

      it "deletes the vertex" do
        expect { subject }.to change { g.V.count.next }.by(-1)
      end
    end

    context "when vertex does not exist" do
      let(:id) { 124 }

      it "deletes the vertex" do
        expect { subject }.not_to(change { g.V.count.next })
      end
    end
  end

  describe "#drop_edge" do
    context "when no arguments passed" do
      subject { repository.drop_edge }

      include_examples "raises an exception", ArgumentError, "either id or from:, to: and label: must be passed"
    end

    context "when deleting by id" do
      subject { repository.drop_edge(id) }

      before do
        g.addV(:test).as(:start).addV(:test).as(:end).addE(:test).from(:start).to(:end).property(T.id, 123).iterate
      end

      context "when edge exists" do
        let(:id) { 123 }

        it "deletes the edge" do
          expect { subject }.to change { g.E.count.next }.by(-1)
        end
      end

      context "when edge does not exist" do
        let(:id) { 124 }

        it "does not delete any edges" do
          expect { subject }.not_to(change { g.E.count.next })
        end
      end
    end

    context "when deleting by from, to and label" do
      context "when all params are passed" do
        subject { repository.drop_edge(from: 1, to: 2, label: :test) }

        before do
          g.addV(:test).property(T.id, 1).as(:start)
           .addV(:test).property(T.id, 2).as(:end)
           .addE(:test).from(:start).to(:end).iterate
        end

        context "when one edge exists" do
          it "deletes the edge" do
            expect { subject }.to change { g.E.count.next }.by(-1)
          end
        end

        context "when multiple edges exist" do
          before do
            g.addE(:test).from(__.V(1)).to(__.V(2)).iterate
          end

          it "deletes only one edge" do
            expect { subject }.to change { g.E.count.next }.by(-1)
          end
        end
      end

      context "when from is missed" do
        subject { repository.drop_edge(to: 123, label: :test) }

        include_examples "raises an exception", ArgumentError, "from:, to: and label: must be passed"
      end

      context "when to is missed" do
        subject { repository.drop_edge(from: 123, label: :test) }

        include_examples "raises an exception", ArgumentError, "from:, to: and label: must be passed"
      end

      context "when label is missed" do
        subject { repository.drop_edge(from: 123, to: 234) }

        include_examples "raises an exception", ArgumentError, "from:, to: and label: must be passed"
      end
    end
  end

  describe "#add_vertex" do
    subject { repository.add_vertex(:test, id, **properties) }

    let(:id) { nil }
    let(:properties) { { key: :value } }

    context "when id is passed as an argument" do
      let(:id) { 123 }

      it "creates a vertex with given id" do
        subject
        expect(g.V(id).next.id).to eq(id)
        expect(g.V(id).elementMap.next).to eq({ T.id => 123, key: "value", T.label => "test" })
      end
    end

    context "when id is passed as an :id property" do
      let(:properties) { super().merge(id: 124) }

      it "creates a vertex with random and an id property" do
        subject
        expect(g.V.has(:key, :value)).not_to eq(124)
        expect(g.V.has(:key, :value).elementMap.next.except(T.id)).to eq({ id: 124, key: "value", T.label => "test" }) # T.id is random
      end
    end

    context "when id is passed as T.id property" do
      let(:properties) { super().merge({ T.id => 124 }) }

      it "creates a vertex with given id" do
        subject
        expect(g.V(124).next.id).to eq(124)
        expect(g.V(124).elementMap.next).to eq({ T.id => 124, key: "value", T.label => "test" })
      end
    end

    context "when id is passed as an argument and as :id" do
      let(:id) { 123 }
      let(:properties) { super().merge(id: 124) }

      it "creates a vertex with given id" do
        subject
        expect(g.V(id).next.id).to eq(id)
        expect(g.V(id).elementMap.next).to eq({ T.id => 123, id: 124, key: "value", T.label => "test" })
      end
    end

    context "when id is passed as an argument and as T.id" do
      let(:id) { 123 }
      let(:properties) { super().merge({ T.id => 124 }) }

      it "creates a vertex with given id" do
        subject
        expect(g.V(id).next.id).to eq(id)
        expect(g.V(id).elementMap.next).to eq({ T.id => 123, key: "value", T.label => "test" })
      end
    end

    context "when id is passed as an argument, as :id and as T.id" do
      let(:id) { 123 }
      let(:properties) { super().merge({ id: 124, T.id => 125 }) }

      it "creates a vertex with given id" do
        subject
        expect(g.V(id).next.id).to eq(id)
        expect(g.V(id).elementMap.next).to eq({ T.id => 123, id: 124, key: "value", T.label => "test" })
      end
    end
  end

  describe "#add_edge" do
    subject { repository.add_edge(:test_label, id, from: from, to: to, **properties) }

    let(:from) { 1 }
    let(:to) { 2 }
    let(:properties) { { key: :value } }

    before do
      g.addV(:test).property(T.id, from)
       .addV(:test).property(T.id, to).iterate
    end

    context "when id is passed as an argument" do
      let(:id) { 123 }

      it "creates an edge" do
        expect { subject }.to change { g.E.count.next }.by(1)
        expect(g.E(id).elementMap.next).to eq({ T.id => 123, T.label => "test_label",
                                                "IN" => { T.id => 2, T.label => "test" },
                                                "OUT" => { T.id => 1, T.label => "test" },
                                                key: "value" })
      end

      context "when id is also passed as a property" do
        let(:properties) { super().merge({ T.id => 124 }) }

        it "creates an edge" do
          expect { subject }.to change { g.E.count.next }.by(1)
          expect(g.E(id).elementMap.next).to eq({ T.id => 123, T.label => "test_label",
                                                  "IN" => { T.id => 2, T.label => "test" },
                                                  "OUT" => { T.id => 1, T.label => "test" },
                                                  key: "value" })
        end
      end
    end

    context "when id is passed as a property" do
      let(:id) { nil }
      let(:properties) { super().merge({ T.id => 124 }) }

      it "creates an edge" do
        expect { subject }.to change { g.E.count.next }.by(1)
        expect(g.E(124).elementMap.next).to eq({ T.id => 124, T.label => "test_label",
                                                 "IN" => { T.id => 2, T.label => "test" },
                                                 "OUT" => { T.id => 1, T.label => "test" },
                                                 key: "value" })
      end
    end
  end

  describe "#upsert_vertex" do
    subject { repository.upsert_vertex(:test, id, create_properties: create_properties, update_properties: update_properties) }

    let(:id) { 123 }
    let(:create_properties) { { key: :value } }
    let(:update_properties) { { another_key: :another_value } }

    context "when vertex does not exist" do
      it "creates a vertex" do
        expect { subject }.to change { g.V.count.next }.by(1)
        expect(g.V(id).elementMap.next).to eq({ T.id => 123, T.label => "test", key: "value", another_key: "another_value" })
      end
    end

    context "when vertex exists" do
      before do
        g.addV(:test).property(T.id, id).property(:some_key, :some_value).iterate
      end

      it "updates a vertex" do
        expect { subject }.not_to(change { g.V.count.next })
        expect(g.V(id).elementMap.next).to eq({ T.id => 123, T.label => "test", some_key: "some_value", another_key: "another_value" })
      end
    end
  end

  describe "#upsert_vertices" do
    subject { repository.upsert_vertices(vertices) }

    let(:vertices) do
      100.times.map do |id| # rubocop:disable Performance/TimesMap
        ["test", id, { some_key: 1 }, { some_other_key: 2 }]
      end
    end

    context "when vertices do not exist" do
      it "upserts all passed vertices" do
        expect { subject }.to change { g.V.count.next }.by(100)
      end

      it "assigns properties" do
        subject
        expect(g.V(99).elementMap.next).to eq({ T.id => 99, T.label => "test", some_key: 1, some_other_key: 2 })
      end
    end

    context "when some vertices exist" do
      before do
        g.addV(:test).property(T.id, 99).iterate
      end

      it "updates existing vertices" do
        subject
        expect(g.V(99).elementMap.next).to eq({ T.id => 99, T.label => "test", some_other_key: 2 })
      end

      it "creates new vertices" do
        expect { subject }.to change { g.V.count.next }.by(99)
      end
    end
  end

  describe "#upsert_edge" do
    subject { repository.upsert_edge(:test, from: from, to: to, create_properties: create_properties, update_properties: update_properties) }

    let(:create_properties) { { key: :value, T.id => 1234 } }
    let(:update_properties) { { another_key: :another_value } }

    let(:from) { 1 }
    let(:to) { 2 }

    before do
      g.addV(:test).property(T.id, from)
       .addV(:test).property(T.id, to).iterate
    end

    context "when edge does not exist" do
      it "creates an edge" do
        expect { subject }.to change { g.E.count.next }.by(1)
        expect(g.E(1234).elementMap.next).to eq({ T.id => 1234, T.label => "test",
                                                  "IN" => { T.id => 2, T.label => "test" },
                                                  "OUT" => { T.id => 1, T.label => "test" },
                                                  another_key: "another_value", key: "value" })
      end
    end

    context "when edge exists" do
      before do
        g.addE(:test).from(__.V(from)).to(__.V(to)).property(T.id, 1234).iterate
      end

      it "does not create new edges" do
        expect { subject }.not_to(change { g.E.count.next })
      end

      it "updates properties with update_properties" do
        subject
        expect(g.E(1234).elementMap.next).to eq({ T.id => 1234, T.label => "test",
                                                  "IN" => { T.id => 2, T.label => "test" },
                                                  "OUT" => { T.id => 1, T.label => "test" },
                                                  another_key: "another_value" })
      end
    end
  end
end
