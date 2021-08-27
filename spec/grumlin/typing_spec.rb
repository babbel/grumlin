# frozen_string_literal: true

RSpec.describe Grumlin::Typing do
  describe ".cast" do
    subject { described_class.cast(value_to_cast) }

    let(:value_to_cast) { { "@type": type, "@value": value } }

    context "when value is a hash" do
      context "when @type is g:List" do
        let(:type) {  "g:List" }

        context "when @value is a list array" do
          let(:value) do
            [{ "@type": "g:Vertex",
               "@value": { id: { "@type": "g:Int32", "@value": 0 }, label: "test_vertex" } }]
          end

          it "returns an array" do
            expect(subject).to(eq([Grumlin::Vertex.new(label: "test_vertex", id: 0)]))
          end
        end

        context "when @value is a an array with a malformed value" do
          let(:value) { [{ "@type": "g:Vertex", "@value": { id: nil, label: "test_vertex" } }] }

          include_examples "raises TypeError", '{:id=>nil, :label=>"test_vertex"} cannot be casted to Grumlin::Vertex'
        end
      end

      context "when @type is g:Map" do
        let(:type) {  "g:Map" }

        context "when @value is a value map array" do
          let(:value) do
            ["test2", { "@type": "g:List", "@value": [{ "@type": "g:Int32", "@value": 0 }] },
             "test1", { "@type": "g:List", "@value": [{ "@type": "g:Int32", "@value": 0 }] }]
          end

          it "returns a hash" do
            expect(subject).to(eq({ test1: [0], test2: [0] }))
          end
        end

        context "when @value is a malformed array" do
          let(:value) do
            ["test2", { "@type": "g:List", "@value": [{ "@type": "g:Int32", "@value": 0 }] }, "test1"]
          end

          include_examples "raises TypeError",
                           '["test2", {:@type=>"g:List", :@value=>[{:@type=>"g:Int32", :@value=>0}]}, "test1"] cannot be casted to Hash'
        end

        context "when @value is a an array with a malformed value" do
          let(:value) do
            ["test2", { "@type": "g:List", "@value": [{ "@type": "g:Int32", "@value": 0 }] },
             "test1", { "@type": "g:List", "@value": nil }]
          end

          include_examples "raises TypeError", '{:@type=>"g:List", :@value=>nil} cannot be casted, @value is missing'
        end
      end

      context "when @type is g:Vertex" do
        let(:type) {  "g:Vertex" }

        context "when @value is an edge hash" do
          let(:value) do
            { label: "vertex", id: 123 }
          end

          it "returns a vertex" do
            expect(subject).to be_an(Grumlin::Vertex)
          end
        end

        context "when @value is a malformed hash" do
          let(:value) { { label: "vertex" } }

          include_examples "raises TypeError", '{:label=>"vertex"} cannot be casted to Grumlin::Vertex'
        end

        context "when @value is something else" do
          let(:value) { 123 }

          include_examples "raises TypeError", "123 cannot be casted to Grumlin::Vertex"
        end
      end

      context "when @type is g:Edge" do
        let(:type) { "g:Edge" }

        context "when @value is an edge hash" do
          let(:value) do
            { label: "edge", id: 123, inVLabel: "vertex", outVLabel: "vertex", inV: "234", outV: "345" }
          end

          it "returns an edge" do
            expect(subject).to be_an(Grumlin::Edge)
          end
        end

        context "when @value is a malformed hash" do
          let(:value) { { label: "edge", id: 123, inVLabel: "vertex" } }

          include_examples "raises TypeError",
                           '{:label=>"edge", :id=>123, :inVLabel=>"vertex"} cannot be casted to Grumlin::Edge'
        end

        context "when @value is something else" do
          let(:value) { 123 }

          include_examples "raises TypeError", "123 cannot be casted to Grumlin::Edge"
        end
      end

      context "when @type is g:Int32" do
        let(:type) {  "g:Int32" }

        context "when @value is an integer" do
          let(:value) { 123 }

          it "returns the value" do
            expect(subject).to eq(123)
          end
        end

        context "when @value is a float" do
          let(:value) { 123.12 }

          include_examples "raises TypeError", "123.12 is not an Integer"
        end

        context "when @value is a hash" do
          let(:value) { {} }

          include_examples "raises TypeError", "{} is not an Integer"
        end
      end

      context "when @type is g:Int64" do
        let(:type) {  "g:Int64" }

        context "when @value is an integer" do
          let(:value) { 123 }

          it "returns the value" do
            expect(subject).to eq(123)
          end
        end

        context "when @value is a float" do
          let(:value) { 123.12 }

          include_examples "raises TypeError", "123.12 is not an Integer"
        end

        context "when @value is a hash" do
          let(:value) { {} }

          include_examples "raises TypeError", "{} is not an Integer"
        end
      end

      context "when hash is not a Gremlin type" do
        let(:value_to_cast) { { some: :hash } }

        include_examples "raises TypeError", "{:some=>:hash} cannot be casted, @type is missing"
      end

      context "when @value is not assigned" do
        let(:type) {  "g:Int64" }
        let(:value) { nil }

        include_examples "raises TypeError", '{:@type=>"g:Int64", :@value=>nil} cannot be casted, @value is missing'
      end
    end

    context "when value is a number" do
      let(:value_to_cast) { 123 }

      it "returns a number" do
        expect(subject).to eq(123)
      end
    end

    context "when value is a string" do
      let(:value_to_cast) { "string" }

      it "returns a string" do
        expect(subject).to eq("string")
      end
    end

    context "when value is nil" do
      let(:value_to_cast) { nil }

      include_examples "raises TypeError", "nil cannot be casted"
    end

    context "when value is an array" do
      let(:value_to_cast) { [] }

      include_examples "raises TypeError", "[] cannot be casted"
    end

    context "when value is an object" do
      let(:value_to_cast) { Object.new }

      include_examples "raises TypeError"
    end
  end
end
