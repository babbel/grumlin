# frozen_string_literal: true

RSpec.describe Grumlin::Sugar do
  let(:object) do
    Class.new do
      include(Grumlin::Sugar)
    end.new
  end

  describe "#__" do
    subject { object.__ }

    it "returns Grumlin::Expressions::U wrapped in Action" do
      expect(subject).to be_an_instance_of(Grumlin::Action)
      expect(subject.action_step).to eq(Grumlin::Expressions::U)
    end
  end

  describe "#g" do
    subject { object.g }

    it "returns a traversal" do
      expect(subject).to be_an_instance_of(Grumlin::Action)
      expect(subject.action_step).to be_an_instance_of(Grumlin::Traversal)
    end
  end
end
