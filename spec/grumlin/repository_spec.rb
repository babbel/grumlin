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

  describe ".new" do
    subject { described_class.new }

    it "returns an empty repository object" do
      expect(subject.class.ancestors).to be_include(described_class::InstanceMethods)
    end
  end

  describe "class methods" do
    %i[shortcut shortcuts shortcuts_from].each do |method|
      it "responds to ##{method}" do
        expect(repository_class).to respond_to(method)
      end
    end
  end

  describe "included shortcuts" do
    it "includes shortcuts" do
      expect(repository_class.shortcuts.names).to eq(%i[props hasAll upsertV upsertE shortcut])
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

    it "imports shortcuts" do
      subject
      expect(repository.g).to respond_to(:another_shortcut)
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

    it "imports shortcuts" do
      subject
      expect(repository.g).to respond_to(:another_shortcut)
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
      subject { repository.test_query(:white) }

      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query, return_mode: :single) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      include_examples "returns a", Grumlin::Vertex
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
      subject { repository.test_query(:white) }

      let(:repository_class) do
        Class.new do
          extend Grumlin::Repository

          query(:test_query, return_mode: :traversal) do |color|
            g.V.hasAll(color: color)
          end
        end
      end

      include_examples "returns a", Grumlin::Step
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
        expect { |b| repository.test_query(:white, &b) }.to yield_with_args(Grumlin::Step)
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
        expect { repository.test_query }.to raise_error(Grumlin::WrongQueryResult, "queries must return Grumlin::Step, nil or an empty collection. Given: String")
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

  describe "overriding standard gremlin steps" do
    let(:repository_class) do
      Class.new do
        extend Grumlin::Repository

        shortcut :addV, override: true do |label|
          super(label).property(:a, :b)
        end
      end
    end

    context "when super is called" do
      it "calls the original step" do
        expect(repository.g.addV("test").bytecode.serialize).to eq({ step: [[:addV, "test"], %i[property a b]] })
      end

      context "when overridden shortcut is inherited" do
        let(:repository_class) do
          Class.new(super())
        end

        it "calls the original step" do
          expect(repository.g.addV("test").bytecode.serialize).to eq({ step: [[:addV, "test"], %i[property a b]] })
        end
      end

      context "when overriden shortcut is overridden again" do
        let(:repository_class) do
          Class.new(super()) do
            shortcut :addV, override: true do |label|
              super(label).property(:b, :c)
            end
          end
        end

        it "calls the previous override and the original step" do
          expect(repository.g.addV("test").bytecode.serialize).to eq({ step: [[:addV, "test"], %i[property a b], %i[property b c]] })
        end
      end
    end
  end

  describe "default properties" do
    let(:repository_class) do
      Class.new do
        extend Grumlin::Repository

        default_vertex_properties do |label|
          {
            node: true,
            default_label: label
          }
        end

        default_edge_properties do |label|
          {
            edge: true,
            default_label: label
          }
        end
      end
    end

    context "when using addV directly" do
      it "assigns default properties" do
        repository.g.addV(:test).property(T.id, :test_node).iterate
        expect(repository.g.V(:test_node).elementMap.next).to eq({ T.id => "test_node", T.label => "test", node: true, default_label: "test" })
      end
    end

    context "when using addE directly" do
      before do
        g.addV(:test).property(T.id, 1).iterate
        g.addV(:test).property(T.id, 2).iterate
      end

      it "assigns default properties" do
        repository.g.addE(:test).property(T.id, :test_edge).from(__.V(1)).to(__.V(2)).iterate
        expect(repository.g.E(:test_edge).elementMap.next).to eq({ T.id => "test_edge", T.label => "test", "IN" => { T.id => 2, T.label => "test" }, "OUT" => { T.id => 1, T.label => "test" }, edge: true, default_label: "test" })
      end
    end

    context "when using add_vertex" do
      it "assigns default properties" do
        repository.add_vertex(:test, T.id => :test_node)
        expect(repository.g.V(:test_node).elementMap.next).to eq({ T.id => "test_node", T.label => "test", node: true, default_label: "test" })
      end
    end

    context "when using add_edge" do
      before do
        g.addV(:test).property(T.id, 1).iterate
        g.addV(:test).property(T.id, 2).iterate
      end

      it "assigns default properties" do
        repository.add_edge(:test, T.id => :test_edge, from: 1, to: 2)
        expect(repository.g.E(:test_edge).elementMap.next).to eq({ T.id => "test_edge", T.label => "test", "IN" => { T.id => 2, T.label => "test" }, "OUT" => { T.id => 1, T.label => "test" }, edge: true, default_label: "test" })
      end
    end

    context "when using upsertV" do
      it "assigns default properties" do
        repository.g.upsertV(:test, :test_node).iterate
        expect(repository.g.V(:test_node).elementMap.next).to eq({ T.id => "test_node", T.label => "test", node: true, default_label: "test" })
      end
    end

    context "when using upsertE" do
      before do
        g.addV(:test).property(T.id, 1).iterate
        g.addV(:test).property(T.id, 2).iterate
      end

      it "assigns default properties" do
        repository.g.upsertE(:test, 1, 2).iterate
        expect(repository.g.E.hasLabel(:test).elementMap.next.except(T.id)).to eq({ T.label => "test", "IN" => { T.id => 2, T.label => "test" }, "OUT" => { T.id => 1, T.label => "test" }, edge: true, default_label: "test" })
      end
    end

    describe "inheritance" do
      let(:repository_class) do
        Class.new(super()) do
          default_vertex_properties do |_label|
            {
              inherited: true
            }
          end

          default_edge_properties do |_label|
            {
              inherited: true
            }
          end
        end
      end

      context "when using addV directly" do
        it "assigns default properties" do
          repository.g.addV(:test).property(T.id, :test_node).iterate
          expect(repository.g.V(:test_node).elementMap.next).to eq({ T.id => "test_node", T.label => "test", node: true, default_label: "test", inherited: true })
        end
      end

      context "when using addE directly" do
        before do
          g.addV(:test).property(T.id, 1).iterate
          g.addV(:test).property(T.id, 2).iterate
        end

        it "assigns default properties" do
          repository.g.addE(:test).property(T.id, :test_edge).from(__.V(1)).to(__.V(2)).iterate
          expect(repository.g.E(:test_edge).elementMap.next).to eq({ T.id => "test_edge", T.label => "test", "IN" => { T.id => 2, T.label => "test" }, "OUT" => { T.id => 1, T.label => "test" }, edge: true, default_label: "test", inherited: true })
        end
      end
    end
  end

  describe "#middlewares" do
    subject { repository_class.middlewares }

    context "when repository is inherited from another repository" do
      let(:base_repository_class) do
        Class.new do
          extend Grumlin::Repository
          middlewares do |b|
            b.use Grumlin::Middlewares::Middleware # does not really matter what class, it won't be executed
          end
        end
      end

      let(:repository_class) { Class.new(base_repository_class) }

      it "returns a copy of the parent middlewares stack" do
        # base_repository_class stores it's additional middleware
        expect(base_repository_class.middlewares).to include(Grumlin::Middlewares::Middleware)
        # changing base_repository_class does not affect default middlewares
        expect(Grumlin.default_middlewares).not_to include(Grumlin::Middlewares::Middleware)
        # Stack is new, but middlewares in it are the same
        expect(subject).not_to eq(base_repository_class.middlewares)
        expect(subject).to be_similar(base_repository_class.middlewares) # stack is protected
      end
    end

    context "when repository is not inherited from another repository" do
      it "returns a copy of the default middleware stack" do
        # Stack is new, but middlewares in it are the same
        expect(subject).not_to eq(Grumlin.default_middlewares)
        expect(subject).to be_similar(Grumlin.default_middlewares) # stack is protected
      end
    end
  end

  describe "read only repository" do
    let(:repository_class) do
      Class.new do
        extend Grumlin::Repository
        read_only!
      end
    end

    context "when running a non-mutating query" do
      subject { repository.g.V.count.next }

      include_examples "does not raise"
    end

    context "when running a mutating query" do
      subject { repository.g.addV(:test).iterate }

      it "works" do
        pp repository.class.middlewares
      end

      include_examples "raises an exception", Grumlin::QueryValidators::Validator::ValidationError, "Query is invalid: {:blocklisted_steps=>[:addV]}"
    end
  end
end
