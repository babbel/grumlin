# frozen_string_literal: true

RSpec.describe Grumlin::StepsSerializers::Bytecode do
  let(:serializer) { described_class.new(steps) }

  let(:shortcuts) do
    {
      hasColor: ->(color) { has(:color, color) },
      hasShape: ->(shape) { has(:shape, shape) },
      hasShapeAndColor: ->(shape, color) { hasShape(shape).hasColor(color) },
      addWeights: -> { withSideEffect(:weights, a: 1, b: 2) },
      preconfigure: -> { addWeights }
    }
  end

  describe "#serialize" do
    subject { serializer.serialize }

    context "when there are no anonymous traversals" do
      let(:steps) { Grumlin::Action.new(:V).has(:color, :white).has(:shape, :rectangle).steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], %i[has color white], %i[has shape rectangle]] })
      end
    end

    context "when there are anonymous traversals" do
      let(:steps) { Grumlin::Action.new(:V).where(Grumlin::Action.new(:has, args: %i[color white])).has(:shape, :rectangle).steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], [:where, [%i[has color white]]], %i[has shape rectangle]] })
      end
    end

    context "when Expressions::T is used" do
      let(:steps) { Grumlin::Action.new(:V).has(Grumlin::Expressions::T.id, "id").steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], [:has, { :@type => "g:T", :@value => :id }, "id"]] })
      end
    end

    context "when Expressions::WithOptions is used" do
      let(:steps) { Grumlin::Action.new(:V).with(Grumlin::Expressions::WithOptions.tokens).steps }

      it "returns a string representation of steps" do
        expect(subject).to eq({ step: [[:V], [:with, "~tinkerpop.valueMap.tokens"]] })
      end
    end
  end
end
