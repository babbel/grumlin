# frozen_string_literal: true

RSpec.describe Grumlin::Repository::ErrorHandlingStrategy do
  let(:strategy) { described_class.new(mode: mode, **params) }
  let(:params) { { on: [NameError] } }

  describe "#apply" do
    subject { strategy.apply! { stub.call } }

    let(:stub) { double(call: "test") } # rubocop:disable RSpec/VerifiedDoubles

    shared_examples "does not retry" do
      it "does not retry" do
        begin
          subject
        rescue StandardError
          nil
        end
        expect(stub).to have_received(:call).once
      end
    end

    context "when mode is :raise" do
      let(:mode) { :raise }

      context "when no error is raised" do
        include_examples "does not retry"

        it "returns result of the block execution" do
          expect(subject).to eq("test")
        end
      end

      context "when an error is raised" do
        before do
          allow(stub).to receive(:call).and_raise(StandardError)
        end

        include_examples "does not retry"
        include_examples "raises an exception", StandardError
      end
    end

    context "when mode is :ignore" do
      let(:mode) { :ignore }

      context "when no errors is raised" do
        include_examples "does not retry"

        it "returns result of the block execution" do
          expect(subject).to eq("test")
        end
      end

      context "when an error from the 'on' list is raised" do
        before do
          allow(stub).to receive(:call).and_raise(NameError)
        end

        include_examples "does not retry"
        include_examples "does not raise"
      end

      context "when an error not from the 'on' list is raised" do
        before do
          allow(stub).to receive(:call).and_raise(StandardError)
        end

        include_examples "does not retry"
        include_examples "raises an exception", StandardError
      end
    end

    context "when mode is :retry" do
      let(:mode) { :retry }

      context "when no errors is raised" do
        include_examples "does not retry"

        it "returns result of the block execution" do
          expect(subject).to eq("test")
        end
      end

      context "when an error from the 'on' list is raised" do
        before do
          allow(stub).to receive(:call).and_raise(NameError)
        end

        it "retries and raises an exception after retry limit is reached" do
          expect { subject }.to raise_error(NameError)
          expect(stub).to have_received(:call).exactly(2).times
        end
      end

      context "when an error not from the 'on' list is raised" do
        before do
          allow(stub).to receive(:call).and_raise(StandardError)
        end

        include_examples "does not retry"

        include_examples "raises an exception", StandardError
      end
    end
  end
end
