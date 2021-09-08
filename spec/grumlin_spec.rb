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
end
