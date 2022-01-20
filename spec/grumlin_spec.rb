# frozen_string_literal: true

RSpec.describe Grumlin do
  it "has a version number" do
    expect(Grumlin::VERSION).not_to be nil
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

  describe "#definitions" do
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
