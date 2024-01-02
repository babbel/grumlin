# frozen_string_literal: true

RSpec.describe Grumlin::WithExtension, :gremlin do
  let(:shortcuts) { Grumlin::Shortcuts::Storage.new }

  let(:klass) do
    Class.new(shortcuts.traversal_start_class) do
      include Grumlin::WithExtension
    end
  end

  let(:traversal_start) { klass.new }

  describe "#with" do
    subject { traversal_start.with(:some_name, "some_value").with(:other_name, "other_value").V.valueMap.with(WithOptions.tokens).bytecode.serialize }

    it "adds withStrategies step with OptionStrategy argument" do
      expect(subject).to eq({ step: [[:V], [:valueMap], [:with, "~tinkerpop.valueMap.tokens"]],
                              source: [[:withStrategies,
                                        { :@type => "g:OptionsStrategy", :@value => { some_name: "some_value", other_name: "other_value" } }]] })
    end
  end
end
