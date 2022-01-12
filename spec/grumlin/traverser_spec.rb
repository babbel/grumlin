# frozen_string_literal: true

RSpec.describe Grumlin::Traverser do
  RSpec.shared_examples "builds a traverser" do |bulk|
    it "assigns bulk" do
      expect(subject.bulk).to eq(bulk)
    end

    it "assigns value" do
      expect(subject.value).to eq({ test1: [0], test2: [0] })
    end

    it "calls Typing.cast for value" do
      expect(Grumlin::Typing).to receive(:cast).and_call_original.exactly(5).times # rubocop:disable RSpec/MessageSpies
      subject
    end
  end

  describe ".new" do
    subject { described_class.new(traverser_value) }

    let(:traverser_value) { { bulk: bulk, value: value } }

    let(:value) do
      { "@type": "g:Map", "@value":  ["test2", { "@type": "g:List", "@value": [{ "@type": "g:Int32", "@value": 0 }] },
                                      "test1", { "@type": "g:List", "@value": [{ "@type": "g:Int32", "@value": 0 }] }] }
    end

    context "when bulk is not specified" do
      let(:traverser_value) { { value: value } }

      include_examples "builds a traverser", 1
    end

    context "when bulk nil" do
      let(:bulk) { nil }

      include_examples "builds a traverser", 1
    end

    context "when bulk value is nil" do
      let(:bulk) { { "@value": nil } }

      include_examples "builds a traverser", 1
    end

    context "when bulk is specified" do
      let(:bulk) { { "@value": 20 } }

      include_examples "builds a traverser", 20
    end
  end
end
