# frozen_string_literal: true

RSpec.describe Grumlin::Edge do
  let(:attrs) { { label: "edge", id: 123, inVLabel: "vertex", outVLabel: "vertex", inV: "234", outV: "345" } }

  describe ".new" do
    it "properly assigns all instance variables" do
      edge = described_class.new(**attrs)
      expect(edge).to have_attributes(attrs)
    end
  end

  describe "#inspect" do
    it "returns string representation of the edge" do
      edge = described_class.new(**attrs)
      expect(edge.inspect).to eq("<E edge(123)>")
    end
  end

  describe "#==" do
    let(:edge) { described_class.new(**attrs) }

    context "when the other object is equal" do
      let(:other_edge) { described_class.new(**attrs) }

      it "returns true" do
        expect(edge).to eq(other_edge)
      end
    end

    context "when the other object is not equal" do
      let(:other_edge) do
        described_class.new(label: "edge", id: 234, inVLabel: "vertex", outVLabel: "vertex", inV: "234", outV: "345")
      end

      it "returns true" do
        expect(edge).not_to eq(other_edge)
      end
    end
  end
end
