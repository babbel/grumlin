# frozen_string_literal: true

RSpec.describe Grumlin::QueryValidators::BlocklistedStepsValidator do
  let(:validator) { described_class.new(:addV, :drop) }

  describe "validation" do
    context "when query contains forbidden steps" do
      describe "#valid?" do
        subject { validator.valid?(steps) }

        it "returns false" do
        end
      end

      describe "#validate!" do
        it "raises a ValidationError" do
        end
      end
    end

    context "when does not cointain forbidden steps" do
      describe "#valid?" do
        subject { validator.valid?(steps) }

        it "returns true" do
        end
      end

      describe "#validate!" do
        it "does not raise any errors" do
        end
      end
    end
  end
end
