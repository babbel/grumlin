# frozen_string_literal: true

RSpec.describe Grumlin::Sugar do
  let(:object) do
    Class.new do
      include(Grumlin::Sugar)
    end.new
  end

  describe "#__" do
    it "returns Grumlin::TraversalStart" do
      expect(object.__).to be_a(Grumlin::TraversalStart)
    end
  end

  describe "#g" do
    it "returns a traversal" do
      expect(object.g).to be_a(Grumlin::TraversalStart)
    end
  end
end
