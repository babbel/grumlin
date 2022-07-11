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

  describe "overriding standard gremlin steps" do
    let(:repository_class) do
      Class.new do
        extend Grumlin::Repository

        shortcut :addV, override: true do |label|
          super(label).property(:a, :b)
        end
      end
    end
    let(:repository) { repository_class.new }

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
end
