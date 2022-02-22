# frozen_string_literal: true

RSpec.describe Grumlin::StepsSerializers::Bytecode, gremlin: true do
  let(:serializer) { described_class.new(steps) }

  let(:shortcuts) do
    {
      hasColor: Grumlin::Shortcut.new(:hasColor) { |color| has(:color, color) },
      hasShape: Grumlin::Shortcut.new(:hasShape) { |shape| has(:shape, shape) },
      hasShapeAndColor: Grumlin::Shortcut.new(:hasShapeAndColor) { |shape, color| hasShape(shape).hasColor(color) },
      addWeights: Grumlin::Shortcut.new(:addWeights) { withSideEffect(:weights, a: 1, b: 2) },
      preconfigure: Grumlin::Shortcut.new(:preconfigure) { addWeights }
    }
  end

  describe "#serialize" do
    subject { serializer.serialize }

    context "when there are no anonymous traversals" do
      let(:steps) { g.V.has(:color, :white).has(:shape, :rectangle).steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], %i[has color white], %i[has shape rectangle]] })
      end
    end

    context "when there are anonymous traversals" do
      let(:steps) { g.V.where(__.has(:color, :white)).has(:shape, :rectangle).steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], [:where, { :@type => "g:Bytecode", :@value => { step: [%i[has color white]] } }], %i[has shape rectangle]] })
      end
    end

    context "when Expressions::T is used" do
      let(:steps) { g.V.has(Grumlin::Expressions::T.id, "id").steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], [:has, { :@type => "g:T", :@value => :id }, "id"]] })
      end
    end

    context "when Expressions::WithOptions is used" do
      let(:steps) { g.V.with(Grumlin::Expressions::WithOptions.tokens).steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], [:with, "~tinkerpop.valueMap.tokens"]] })
      end
    end
  end
end
