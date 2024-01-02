# frozen_string_literal: true

RSpec.describe Grumlin::QueryValidators::BlocklistedStepsValidator, :gremlin do
  let(:validator) { described_class.new(:addV, :drop) }

  shared_examples "considers query valid" do
    describe "#valid?" do
      subject { validator.valid?(steps) }

      include_examples "returns true"
    end

    describe "#validate!" do
      subject { validator.validate!(steps) }

      include_examples "does not raise"
    end
  end

  shared_examples "considers query invalid" do |error|
    describe "#valid?" do
      subject { validator.valid?(steps) }

      include_examples "returns false"
    end

    describe "#validate!" do
      subject { validator.validate!(steps) }

      include_examples "raises an exception", Grumlin::QueryValidators::Validator::ValidationError, error
    end
  end

  context "when query does not have blocklisted steps" do
    let(:steps) { g.V.where(__.out.has(:a, 1)).steps }

    include_examples "considers query valid"
  end

  context "when query has blocklisted steps in the main traversal" do
    let(:steps) { g.addV(:test).steps }

    include_examples "considers query invalid", "Query is invalid: {:blocklisted_steps=>[:addV]}"
  end

  context "when query has blocklisted steps in the anonymous traversal" do
    let(:steps) { g.V.has(:a, 1).sideEffect(__.out.drop).steps }

    include_examples "considers query invalid", "Query is invalid: {:blocklisted_steps=>[:drop]}"
  end
end
