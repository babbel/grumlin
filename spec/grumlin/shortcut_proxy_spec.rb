# frozen_string_literal: true

RSpec.describe Grumlin::ShortcutProxy do
  let(:proxy) { described_class.new(object, shortcuts) }

  let(:object) { double(fold: true, property: true) } # rubocop:disable RSpec/VerifiedDoubles
  let(:shortcuts) do
    {
      custom_step: proc { |arg| property(:a, arg) }
    }
  end

  describe "#respond_to_missing?" do
    subject { proxy.respond_to_missing?(method_name) }

    context "when method exists in the wrapped object" do
      let(:method_name) { "fold" }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "when method is a shortcut" do
      let(:method_name) { "custom_step" }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "when method is neither a shortcut nor object's method" do
      let(:method_name) { "unknown" }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end

  describe "#method_missing" do
    subject { proxy.method_missing(method_name, *args) }

    let(:args) { [] }

    context "when result is not a step" do
      let(:object) { double(fold: 1, property: 2) } # rubocop:disable RSpec/VerifiedDoubles

      context "when method exists in the wrapped object" do
        let(:method_name) { :fold }

        it "delegates to object" do
          subject
          expect(object).to have_received(:fold)
        end

        it "returns a ShortcutProxy" do
          expect(subject).to eq(1)
        end
      end

      context "when method is a shortcut" do
        let(:method_name) { :custom_step }
        let(:args) { [1] }

        it "executes the shortcut in the context of the proxy" do
          subject
          expect(object).to have_received(:property).with(:a, 1)
        end

        it "returns a ShortcutProxy" do
          expect(subject).to eq(2)
        end
      end
    end

    context "when result is a step" do
      let(:object) { double(fold: Grumlin::AnonymousStep.new("step"), property: Grumlin::AnonymousStep.new("step")) } # rubocop:disable RSpec/VerifiedDoubles

      context "when method exists in the wrapped object" do
        let(:method_name) { :fold }

        it "delegates to object" do
          subject
          expect(object).to have_received(:fold)
        end

        it "returns a ShortcutProxy" do
          expect(subject).to be_a(described_class)
        end
      end

      context "when method is a shortcut" do
        let(:method_name) { :custom_step }
        let(:args) { [1] }

        it "executes the shortcut in the context of the wrapper_object" do
          subject
          expect(object).to have_received(:property).with(:a, 1)
        end

        it "returns a ShortcutProxy" do
          expect(subject).to be_a(described_class)
        end
      end

      context "when method is neither a shortcut nor object's method" do
        let(:method_name) { :unknown }

        include_examples "raises an exception", NameError
      end
    end
  end

  describe "#inspect" do
    subject { proxy.inspect }

    it "delegates to object" do
      allow(object).to receive(:inspect).and_return("object")
      expect(subject).to eq("object")
    end
  end

  describe "#to_s" do
    subject { proxy.to_s }

    it "delegates to object" do
      allow(object).to receive(:to_s).and_return("object")
      expect(subject).to eq("object")
    end
  end
end
