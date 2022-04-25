# frozen_string_literal: true

RSpec.describe Grumlin::Repository, gremlin_server: true do
  let(:repository_class) do
    Class.new do
      extend Grumlin::Repository

      shortcut :shortcut do
        property(:shortcut, true)
      end
    end
  end
  let(:repository) { repository_class.new }

  describe "class methods" do
    %i[shortcut shortcuts shortcuts_from].each do |method|
      it "responds to ##{method}" do
        expect(repository_class).to respond_to(method)
      end
    end
  end

  describe "instance methods" do
    describe "#__" do
      it "returns TraversalStart" do
        expect(repository.__).to be_an_instance_of(Grumlin::TraversalStart)
      end
    end

    describe "#g" do
      it "returns TraversalStart" do
        expect(repository.g).to be_an_instance_of(Grumlin::TraversalStart)
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

  describe "included shortcuts" do
    it "includes shortcuts" do
      expect(repository_class.shortcuts.keys).to eq(%i[props hasAll shortcut])
    end
  end

  describe "extending" do
    context "when not inherited" do
      it "can be extended multiple times" do
        expect { repository_class.extend(described_class) }.not_to raise_error
      end
    end

    context "when inherited" do
      it "can be extended again" do
        expect do
          Class.new(repository_class) do
            extend Grumlin::Repository
          end
        end.not_to raise_error
      end
    end
  end

  describe "inheritance" do
    describe "when inherited" do
      let(:child) { Class.new(repository_class) }

      it "injects it's shortcuts to the child class" do
        expect(child.new.g).to respond_to(:shortcut)
      end
    end
  end

  describe "importing shortcuts from a module" do
    subject { repository_class.shortcuts_from(shortcut_module) }

    let(:shortcut_module) do
      Module.new do
        extend Grumlin::Shortcuts

        shortcut :another_shortcut do
          property(:another_shortcut, true)
        end
      end
    end

    context "when there are no shortcut naming conflicts" do
      it "imports shortcuts" do
        subject
        expect(repository.g).to respond_to(:another_shortcut)
      end
    end

    context "when there is a naming conflict" do
      context "when conflicting shortcuts point to one implementation" do
        before do
          repository_class.shortcuts_from(shortcut_module)
        end

        it "successfully imports shortcuts" do
          expect { subject }.not_to raise_error
        end
      end

      context "when conflicting shortcuts point to different implementations" do
        let(:another_shortcut_module) do
          Module.new do
            extend Grumlin::Shortcuts

            shortcut :another_shortcut do
              property(:another_shortcut, true)
            end
          end
        end

        before do
          repository_class.shortcuts_from(another_shortcut_module)
        end

        include_examples "raises an exception", ArgumentError, "shortcut 'another_shortcut' already exists"
      end
    end
  end

  describe "importing shortcuts from another repository" do
    subject { repository_class.shortcuts_from(another_repository_class) }

    let(:another_repository_class) do
      Class.new do
        extend Grumlin::Repository

        shortcut :another_shortcut do
          property(:another_shortcut, true)
        end
      end
    end

    context "when there are no shortcut naming conflicts" do
      it "imports shortcuts" do
        subject
        expect(repository.g).to respond_to(:another_shortcut)
      end
    end

    context "when there is a naming conflict" do
      context "when conflicting shortcuts point to one implementation" do
        let(:another_repository_class) do
          Class.new do # props and hasAll in this case
            extend Grumlin::Repository
          end
        end

        before do
          repository_class.shortcuts_from(another_repository_class)
        end

        it "successfully imports shortcuts" do
          expect { subject }.not_to raise_error
        end
      end

      context "when conflicting shortcuts point to different implementations" do
        let(:yet_another_repository_class) do
          Class.new do
            extend Grumlin::Repository

            shortcut :another_shortcut do
              property(:another_shortcut, true)
            end
          end
        end

        before do
          repository_class.shortcuts_from(yet_another_repository_class)
        end

        include_examples "raises an exception", ArgumentError, "shortcut 'another_shortcut' already exists"
      end
    end
  end

  describe "#query" do
    context "when return_mode is passed" do
      subject { repository_class.query(:test_query, return_mode: return_mode) { g.V } }

      context "when return mode is valid" do
        let(:return_mode) { :single }

        it "defines a method named after the query" do
          subject
          expect(repository).to respond_to(:test_query)
        end
      end

      context "when return is not valid" do
        let(:return_mode) { :unknown }

        include_examples "raises an exception", ArgumentError, "unsupported return mode unknown. Supported modes: [:list, :none, :single, :traversal]"
      end
    end

    context "when postprocess_with is passed" do
      subject { repository_class.query(:test_query, postprocess_with: postprocess_with) { g.V } }

      context "when postprocess_with is a symbol" do
        let(:postprocess_with) { :present }

        it "defines a method named after the query" do
          subject
          expect(repository).to respond_to(:test_query)
        end
      end

      context "when postprocess_with is callable" do
        let(:postprocess_with) { ->(r) {} }

        it "defines a method named after the query" do
          subject
          expect(repository).to respond_to(:test_query)
        end
      end

      context "when postprocess_with is something else" do
        let(:postprocess_with) { 100_500 }

        include_examples "raises an exception", ArgumentError, "postprocess_with must be a String, Symbol or a callable object, given: Integer"
      end
    end
  end

  describe "queries" do
    before do
      g.addV(:test_node).property(:color, :white).iterate
    end

    context "when query has default return mode" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query :test_query do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      it "returns a non empty list" do
        result = repository.test_query(:white)

        expect(result).to be_an(Array)
        expect(result).not_to be_empty
      end
    end

    context "when query has single return mode" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query, return_mode: :single) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      it "returns a Grumlin::Vertex" do
        result = repository.test_query(:white)

        expect(result).to be_an(Grumlin::Vertex)
      end
    end

    context "when query has none return mode" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query, return_mode: :none) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      it "returns an empty list" do
        result = repository.test_query(:white)

        expect(result).to eq([])
      end
    end

    context "when query has traversal return mode" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query, return_mode: :traversal) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      it "returns a Grumlin::action" do
        result = repository.test_query(:white)

        expect(result).to be_an(Grumlin::Action)
      end
    end

    context "when preconfigured return mode is overwritten" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query, return_mode: :list) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      it "follows the overwritten mode" do
        result = repository.test_query(:white, query_params: { return_mode: :single })

        expect(result).to be_an(Grumlin::Vertex)
      end
    end

    context "when in profiling mode" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      it "returns profiling data" do
        result = repository.test_query(:white, query_params: { profile: true })

        expect(result.keys).to match_array(%i[dur metrics]) # Profiling data
      end
    end

    context "when a block is given" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      it "yields the traversal" do
        expect { |b| repository.test_query(:white, &b) }.to yield_with_args(Grumlin::Action)
      end
    end

    context "when a query block returns an unexpected value" do
      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query) do
            "test"
          end
        end
      end

      it "raises an exception" do
        expect { repository.test_query }.to raise_error(Grumlin::WrongQueryResult, "queries must return Grumlin::Action, nil or an empty collection. Given: String")
      end
    end

    context "when postprocess_with is passed" do
      context "when postprocess_with is a symbol or string" do
        context "when method exists" do
          let(:repository_class) do
            Class.new do
              extend Grumlin::Repository

              query(:test_query, postprocess_with: :present) do
                g.V
              end

              private

              def present(_collection)
                "test"
              end
            end
          end

          it "returns postprocessed data" do
            expect(repository.test_query).to eq("test")
          end
        end

        context "when method does not exist" do
          let(:repository_class) do
            Class.new do
              extend Grumlin::Repository

              query(:test_query, postprocess_with: :present) do
                g.V
              end
            end
          end

          it "raises an error" do
            expect { repository.test_query }.to raise_error(NoMethodError)
          end
        end
      end

      context "when postprocess_with is a lambda" do
        let(:repository_class) do
          Class.new do
            extend Grumlin::Repository

            query(:test_query, postprocess_with: ->(_r) { "test" }) do
              g.V
            end
          end
        end

        it "returns postprocessed data" do
          expect(repository.test_query).to eq("test")
        end
      end
    end
  end
end
