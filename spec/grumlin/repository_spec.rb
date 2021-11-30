# frozen_string_literal: true

RSpec.describe Grumlin::Repository, gremlin_server: true do
  let(:repository_klass) do
    Class.new do
      extend Grumlin::Repository
    end
  end
  let(:repository) { repository_klass.new }

  describe "class methods" do
    %i[shortcut shortcuts shortcuts_from with_shortcuts].each do |method|
      it "responds to ##{method}" do
        expect(repository_klass).to respond_to(method)
      end
    end
  end

  describe "instance methods" do
    %i[__ g].each do |method|
      it "responds to ##{method}" do
        expect(repository).to respond_to(method)
      end
    end
  end

  describe "included shortcuts" do
    it "includes props and hasAll shortcuts" do
      expect(repository_klass.shortcuts.keys).to eq(%i[props hasAll])
    end
  end
end
