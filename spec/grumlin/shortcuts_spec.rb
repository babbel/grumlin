# frozen_string_literal: true

RSpec.describe Grumlin::Shortcuts do
  let(:klass) do
    Class.new do
      extend Grumlin::Shortcuts

      shortcut(:test_step1) { nil }
    end
  end

  describe "inheritance" do
    let(:another_klass) do
      Class.new(klass) do
        shortcut :shortcut1 do
          property(:some_property, true)
        end
      end
    end

    it "allows using shortcuts defined in the ancestor" do
      expect(another_klass.shortcuts.names).to eq(%i[test_step1 shortcut1])
    end
  end

  describe ".shortcut" do
    context "when shortcut name conflicts with gremlin steps" do
      subject { klass.shortcut(:has) { nil } }

      include_examples "raises an exception", ArgumentError, "cannot use names of standard gremlin steps"
    end

    context "when shortcut name conflicts with other shortcut" do
      subject { klass.shortcut(:test_step1) { nil } }

      include_examples "raises an exception", ArgumentError, "shortcut 'test_step1' already exists"
    end

    context "when shortcut has no conflicts" do
      it "add a new shortcut" do
        klass.shortcut(:custom_step) { nil }
        expect(klass.shortcuts.names).to eq(%i[test_step1 custom_step])
        expect(klass.shortcuts[:custom_step]).to be_a(Grumlin::Shortcut)
      end
    end
  end

  describe ".shortcuts_from" do
    let(:another_klass) do
      Class.new do
        extend Grumlin::Shortcuts

        shortcut(:test_step2) { nil }
        shortcut(:test_step3) { nil }
      end
    end

    it "adds all shortcuts from another class" do
      klass.shortcuts_from(another_klass)
      expect(klass.shortcuts.names).to eq(%i[test_step1 test_step2 test_step3])
    end
  end
end
