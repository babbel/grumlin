# frozen_string_literal: true

RSpec.describe Grumlin do
  it "has a version number" do
    expect(Grumlin::VERSION).not_to be_nil
  end

  describe Grumlin::UnknownResponseStatus do
    it "properly assigns message" do
      exception = described_class.new({ code: 999 })
      expect(exception.message).to eq("unknown response status code 999")
      expect(exception.status).to eq({ code: 999 })
    end
  end

  describe Grumlin::ServerSideError do
    it "properly assigns message" do
      exception = described_class.new({ code: 999, message: "error message" }, {})
      expect(exception.message).to eq("error message")
      expect(exception.status).to eq({ code: 999, message: "error message" })
    end
  end

  describe Grumlin::AlreadyExistsError do
    subject { described_class.new(status, []) }

    context "when message contains an id" do
      let(:status) { { message: "Vertex with id already exists: test_id" } }

      it "parses and assigns parsed id" do
        expect(subject.id).to eq("test_id")
      end
    end

    # AWS neptune does not return an id for some reason
    context "when message does not contain an id" do
      let(:status) { { message: "Vertex with id already exists: " } }

      it "does not fail and does not assign id" do
        expect(subject.id).to be_nil
      end
    end
  end

  describe "#definitions" do
    # if these tests fail try running `rake definitions:format`
    describe "[:steps]" do
      subject { described_class.definitions[:steps] }

      it "consists of sorted lists which do not have duplicates" do
        subject.each_value do |list|
          expect(list).to eq(list.sort)
          expect(list).to eq(list.uniq)
        end
      end
    end

    describe "[:expressions]" do
      subject { described_class.definitions[:expressions] }

      it "consists of sorted lists which do not have duplicates" do
        subject.except(:with_options).each_value do |list|
          expect(list).to eq(list.sort)
          expect(list).to eq(list.uniq)
        end
      end
    end
  end
end
