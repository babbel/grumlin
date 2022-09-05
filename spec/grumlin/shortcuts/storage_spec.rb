# frozen_string_literal: true

RSpec.describe Grumlin::Shortcuts::Storage do
  let(:storage) { described_class.new(shortcuts) }
  let(:shortcuts) { { foo: Grumlin::Shortcut.new(:foo) { nil }, bar: bar_shortcut } }
  let(:bar_shortcut) { Grumlin::Shortcut.new(:bar) { nil } }

  describe ".[]" do
    subject { described_class.new({ a: Grumlin::Shortcut.new(:a) { nil }, b: Grumlin::Shortcut.new(:b) { nil } }) }

    it "creates a new storage with given shortcuts" do
      expect(subject.names).to eq(%i[a b])
    end
  end

  describe "#==" do
    subject { storage == another_storage }

    let(:another_storage) { described_class.new(another_shortcuts) }

    context "when storages are equal" do
      let(:another_shortcuts) { shortcuts }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "when storage are not equal" do
      let(:another_shortcuts) { { c: Grumlin::Shortcut.new(:c) { nil }, d: Grumlin::Shortcut.new(:d) { nil } } }

      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end

  describe "#add" do
    subject { storage.add(name, bar_shortcut) }

    context "when shortcut does not exist" do
      let(:name) { :baz }

      it "adds a new shortcut" do
        expect { subject }.to change(storage, :names).from(%i[foo bar]).to(%i[foo bar baz])
      end
    end

    context "when shortcut exists" do
      context "when shortcut is the same same" do
        let(:name) { :bar }

        it "does not do anything" do
          expect { subject }.not_to raise_error
          expect(storage.names).to eq(%i[foo bar])
        end
      end
    end
  end

  describe "#add_from" do
    subject { storage.add_from(another_storage) }

    let(:another_storage) { described_class.new({ baz: Grumlin::Shortcut.new(:baz) { nil } }) }

    it "adds all shortcuts from another storage" do
      subject
      expect(storage.names).to eq(%i[foo bar baz])
    end
  end

  describe "#g" do
    subject { storage.g }

    it "returns TraversalStart" do
      expect(subject).to be_an(Grumlin::TraversalStart)
      expect(subject).to respond_to(:foo)
      expect(subject).to respond_to(:bar)
    end
  end

  describe "#__" do
    subject { storage.__ }

    it "returns TraversalStart" do
      expect(subject).to be_an(Grumlin::TraversalStart)
      expect(subject).to respond_to(:foo)
      expect(subject).to respond_to(:bar)
    end
  end

  describe "#traversal_start_class" do
    subject { storage.traversal_start_class }

    it "returns a TraversalStart subclass" do
      expect(subject.superclass).to eq(Grumlin::TraversalStart)
      expect(subject.instance_methods).to include(:foo)
      expect(subject.instance_methods).to include(:bar)
    end
  end

  describe "#step_class" do
    subject { storage.step_class }

    it "returns a Step subclass" do
      expect(subject.superclass).to eq(Grumlin::Step)
      expect(subject.instance_methods).to include(:foo)
      expect(subject.instance_methods).to include(:bar)
    end
  end
end
