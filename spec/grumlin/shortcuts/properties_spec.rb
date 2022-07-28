# frozen_string_literal: true

RSpec.describe Grumlin::Shortcuts::Properties do
  describe "shortcut props" do
    context "when cardinality is not passed" do
      it "converts a hash into a charin of property calls" do
        object1 = double(property: nil) # rubocop:disable RSpec/VerifiedDoubles
        object = double(property: object1) # rubocop:disable RSpec/VerifiedDoubles
        described_class.shortcuts[:props].apply(object, a: 1, b: 2)
        expect(object).to have_received(:property).with(:a, 1)
        expect(object1).to have_received(:property).with(:b, 2)
      end
    end

    context "when cardinality is passed" do
      it "converts a hash into a charin of property calls" do
        object1 = double(property: nil) # rubocop:disable RSpec/VerifiedDoubles
        object = double(property: object1) # rubocop:disable RSpec/VerifiedDoubles
        described_class.shortcuts[:props].apply(object, Grumlin::Expressions::Cardinality.single, a: 1, b: 2)
        expect(object).to have_received(:property).with(Grumlin::Expressions::Cardinality.single, :a, 1)
        expect(object1).to have_received(:property).with(Grumlin::Expressions::Cardinality.single, :b, 2)
      end
    end
  end

  describe "shortcut hasAll" do
    it "converts a hash into a charin of has calls" do
      object1 = double(has: nil) # rubocop:disable RSpec/VerifiedDoubles
      object = double(has: object1) # rubocop:disable RSpec/VerifiedDoubles
      described_class.shortcuts[:hasAll].apply(object, a: 1, b: 2)
      expect(object).to have_received(:has).with(:a, 1)
      expect(object1).to have_received(:has).with(:b, 2)
    end
  end
end
