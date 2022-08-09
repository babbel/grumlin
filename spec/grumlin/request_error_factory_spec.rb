# frozen_string_literal: true

RSpec.describe Grumlin::RequestErrorFactory do
  describe ".build" do
    subject { described_class.build(request, response) }

    let(:request) { { request: {} } }

    context "when status is 200" do
      let(:response) { { requestId: 123, status: { code: 200, message: "ok" } } }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when status is 500" do
      let(:response) { { requestId: 123, status: { code: 500, message: message } } }

      context "when vertex already exists" do
        let(:message) { "Vertex with id already exists: 1234" }

        include_examples "returns an exception", Grumlin::VertexAlreadyExistsError
      end

      context "when edge already exists" do
        let(:message) { "Edge with id already exists: 1234" }

        include_examples "returns an exception", Grumlin::EdgeAlreadyExistsError
      end

      context "when concurrent vertex insert failed" do
        let(:message) { "Failed to complete Insert operation for a Vertex due to conflicting concurrent" }

        include_examples "returns an exception", Grumlin::ConcurrentVertexInsertFailedError
      end

      context "when concurrent edge insert failed" do
        let(:message) { "Failed to complete Insert operation for an Edge due to conflicting concurrent" }

        include_examples "returns an exception", Grumlin::ConcurrentEdgeInsertFailedError
      end

      context "when concurrent modification failed" do
        let(:message) { "Failed to complete operation due to conflicting concurrent" }

        include_examples "returns an exception", Grumlin::ConcurrentModificationError
      end
    end

    context "when status is 499" do
      context "when status is 499" do
        let(:response) { { requestId: 123, status: { code: 499, message: "" } } }

        include_examples "returns an exception", Grumlin::InvalidRequestArgumentsError
      end
    end

    context "when status is 597" do
      let(:response) { { requestId: 123, status: { code: 597, message: "" } } }

      include_examples "returns an exception", Grumlin::ScriptEvaluationError
    end

    context "when status is 599" do
      let(:response) { { requestId: 123, status: { code: 599, message: "" } } }

      include_examples "returns an exception", Grumlin::ServerSerializationError
    end

    context "when status is 598" do
      let(:response) { { requestId: 123, status: { code: 598, message: "" } } }

      include_examples "returns an exception", Grumlin::ServerTimeoutError
    end

    context "when status is 401" do
      let(:response) { { requestId: 123, status: { code: 401, message: "" } } }

      include_examples "returns an exception", Grumlin::ClientSideError
    end

    context "when status is 407" do
      let(:response) { { requestId: 123, status: { code: 407, message: "" } } }

      include_examples "returns an exception", Grumlin::ClientSideError
    end

    context "when status is 498" do
      let(:response) { { requestId: 123, status: { code: 498, message: "" } } }

      include_examples "returns an exception", Grumlin::ClientSideError
    end

    context "when status is unknown" do
      let(:response) { { requestId: 123, status: { code: -1, message: "" } } }

      include_examples "returns an exception", Grumlin::UnknownResponseStatus
    end
  end
end
