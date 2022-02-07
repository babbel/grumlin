# frozen_string_literal: true

RSpec.describe Grumlin::Repository, gremlin_server: true do
  let(:repository_class) do
    Class.new do
      extend Grumlin::Repository

      shortcut :shortcut_with_configuration_steps do
        withSideEffect(:a, 1)
          .withSideEffect(:b, 2)
      end

      shortcut :shortcut_with_other_shortcuts do
        shortcut_with_configuration_steps
      end

      shortcut :shortcut do
        property(:shortcut, true)
      end

      def foo(id1, id2)
        g.addE("test").from(__.V(id1)).to(__.V(id2)).props(a: 1).iterate
      end
    end
  end
  let(:repository) { repository_class.new }

  describe "class methods" do
    %i[shortcut shortcuts shortcuts_from].each do |method|
      it "responds to ##{method}" do
        expect(repository_class).to respond_to(method)
      end
    end
  end

  describe "instance methods" do
    %i[__ g with_shortcuts].each do |method|
      it "responds to ##{method}" do
        expect(repository).to respond_to(method)
      end
    end
  end

  describe "included shortcuts" do
    it "includes shortcuts" do
      expect(repository_class.shortcuts.keys).to eq(%i[props hasAll shortcut_with_configuration_steps shortcut_with_other_shortcuts shortcut])
    end
  end

  describe "extending" do
    context "when not inherited" do
      it "can be extended multiple times" do
        expect { repository_class.extend(described_class) }.not_to raise_error
      end
    end

    context "when inherited" do
      it "can be extended again" do
        expect do
          Class.new(repository_class) do
            extend Grumlin::Repository
          end
        end.not_to raise_error
      end
    end
  end

  describe "inheritance" do
    describe "when inherited" do
      let(:child) { Class.new(repository_class) }

      it "injects it's shortcuts to the child class" do
        expect(child.new.g).to respond_to(:shortcut)
      end
    end
  end

  describe "importing shortcuts from a module" do
    subject { repository_class.shortcuts_from(shortcut_module) }

    let(:shortcut_module) do
      Module.new do
        extend Grumlin::Shortcuts

        shortcut :another_shortcut do
          property(:another_shortcut, true)
        end
      end
    end

    context "when there are no shortcut naming conflicts" do
      it "imports shortcuts" do
        subject
        expect(repository.g).to respond_to(:another_shortcut)
      end
    end

    context "when there is a naming conflict" do
      context "when conflicting shortcuts point to one implementation" do
        before do
          repository_class.shortcuts_from(shortcut_module)
        end

        it "successfully imports shortcuts" do
          expect { subject }.not_to raise_error
        end
      end

      context "when conflicting shortcuts point to different implementations" do
        let(:another_shortcut_module) do
          Module.new do
            extend Grumlin::Shortcuts

            shortcut :another_shortcut do
              property(:another_shortcut, true)
            end
          end
        end

        before do
          repository_class.shortcuts_from(another_shortcut_module)
        end

        include_examples "raises an exception", ArgumentError, "shortcut 'another_shortcut' already exists"
      end
    end
  end

  describe "importing shortcuts from another repository" do
    subject { repository_class.shortcuts_from(another_repository_class) }

    let(:another_repository_class) do
      Class.new do
        extend Grumlin::Repository

        shortcut :another_shortcut do
          property(:another_shortcut, true)
        end
      end
    end

    context "when there are no shortcut naming conflicts" do
      it "imports shortcuts" do
        subject
        expect(repository.g).to respond_to(:another_shortcut)
      end
    end

    context "when there is a naming conflict" do
      context "when conflicting shortcuts point to one implementation" do
        let(:another_repository_class) do
          Class.new do # props and hasAll in this case
            extend Grumlin::Repository
          end
        end

        before do
          repository_class.shortcuts_from(another_repository_class)
        end

        it "successfully imports shortcuts" do
          expect { subject }.not_to raise_error
        end
      end

      context "when conflicting shortcuts point to different implementations" do
        let(:yet_another_repository_class) do
          Class.new do
            extend Grumlin::Repository

            shortcut :another_shortcut do
              property(:another_shortcut, true)
            end
          end
        end

        before do
          repository_class.shortcuts_from(yet_another_repository_class)
        end

        include_examples "raises an exception", ArgumentError, "shortcut 'another_shortcut' already exists"
      end
    end
  end

  it "works", timeout: 2 do
    repository.g.addV("test").props(T.id => 1)
              .addV("test").props(T.id => 2).iterate
    # repository.g.shortcut_with_configuration_steps.class
    # repository.g.shortcut_with_configuration_steps.shortcut_with_other_shortcuts.class
    # repository.g.shortcut_with_configuration_steps.shortcut_with_other_shortcuts.V.select(:test)
    repository.foo(1, 2)
  end
end
