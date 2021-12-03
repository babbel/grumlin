# frozen_string_literal: true

RSpec.describe Grumlin::Sugar do
  let(:object) do
    Class.new do
      include(Grumlin::Sugar)
    end.new
  end

  describe "#__" do
    it "returns Grumlin::Expressions::U" do
      expect(object.__).to eq(Grumlin::Expressions::U)
    end
  end

  describe "#g" do
    it "returns a traversal" do
      expect(object.g).to be_a(Grumlin::Traversal)
    end
  end
end
