# frozen_string_literal: true

RSpec.describe Grumlin::Sugar do
  let(:object) do
    Class.new do
      include(Grumlin::Sugar)
    end.new
  end

  describe "#__" do
    subject { object.__ }

    include_examples "returns a", Grumlin::TraversalStart
  end

  describe "#g" do
    subject { object.g }

    include_examples "returns a", Grumlin::TraversalStart
  end
end
