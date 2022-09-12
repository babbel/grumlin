# frozen_string_literal: true

RSpec.describe Grumlin::RequestDispatcher, async: true do
  let(:dispatcher) { described_class.new }

  describe "#add_request" do
    subject { dispatcher.add_request({ requestId: 123 }) }

    context "when request is new" do
      it "adds a request" do
        expect { subject }.to change { dispatcher.requests.count }.by(1)
        expect(dispatcher.requests[123][:request]).to eq({ requestId: 123 })
        expect(dispatcher.requests[123][:result]).to eq([])
        expect(dispatcher.requests[123][:channel]).to be_an_instance_of(Async::Channel)
      end
    end

    context "when request has already been added" do
      before do
        dispatcher.add_request({ requestId: 123 })
      end

      include_examples "raises an exception", described_class::RequestAlreadyAddedError

      it "does not add the request" do
        expect do
          subject
        rescue StandardError
          nil
        end.not_to(change { dispatcher.requests.count })
      end
    end
  end

  describe "#add_response" do
    subject { dispatcher.add_response(response) }

    context "when request is known" do
      before do
        dispatcher.add_request({ requestId: 123 })
      end

      context "when result is successful" do
        context "when status is 200" do
          let(:response) { { requestId: 123, status: { code: 200 }, result: { data: "some data" } } }

          context "when there were no partial content responses previously" do
            it "sends results via the response channel" do
              channel = dispatcher.requests[123][:channel]
              task = Async do
                expect(channel.dequeue).to eq(["some data"])
              end
              subject
              task.wait
            end

            it "removes the request" do
              expect { subject }.to change { dispatcher.requests[123] }.from(Hash).to(nil)
            end

            it "closes the response channel" do
              channel = dispatcher.requests[123][:channel]
              expect { subject }.to change(channel, :closed?).from(false).to(true)
            end
          end

          context "when there were a partial content response previously" do
            before do
              dispatcher.add_response({ requestId: 123, status: { code: 206 }, result: { data: "some partial data" } })
            end

            it "sends full results via the response channel" do
              channel = dispatcher.requests[123][:channel]
              task = Async do
                expect(channel.dequeue).to eq(["some partial data", "some data"])
              end
              subject
              task.wait
            end

            it "removes the request" do
              expect { subject }.to change { dispatcher.requests[123] }.from(Hash).to(nil)
            end

            it "closes the response channel" do
              channel = dispatcher.requests[123][:channel]
              expect { subject }.to change(channel, :closed?).from(false).to(true)
            end
          end
        end

        context "when status is 204" do
          let(:response) { { requestId: 123, status: { code: 204 } } }

          it "sends results via the response channel" do
            channel = dispatcher.requests[123][:channel]
            task = Async do
              expect(channel.dequeue).to eq([])
            end
            subject
            task.wait
          end

          it "removes the request" do
            expect { subject }.to change { dispatcher.requests[123] }.from(Hash).to(nil)
          end

          it "closes the response channel" do
            channel = dispatcher.requests[123][:channel]
            expect { subject }.to change(channel, :closed?).from(false).to(true)
          end
        end

        context "when status is 206" do
          let(:response) { { requestId: 123, status: { code: 206 }, result: { data: "some partial data" } } }

          it "does not send anything via the response channel" do
            channel = dispatcher.requests[123][:channel]
            task = Async do
              expect(channel.dequeue).to be_nil
            end
            subject
            # dispatcher does not close the channel because it waits for new results
            # in order to unblock the coroutine we need to close it manually.
            channel.close
            task.wait
          end

          it "adds the partial results to the request results" do
            expect { subject }.to(change { dispatcher.requests[123][:result] }.from([]).to(["some partial data"]))
          end

          it "does not remove the request" do
            expect { subject }.not_to(change { dispatcher.requests.count })
          end

          it "does not close the response channel" do
            channel = dispatcher.requests[123][:channel]
            expect { subject }.not_to change(channel, :closed?)
          end
        end
      end

      context "when result is an error" do
        shared_examples "sends an exception via the response channel" do |exception|
          it "sends #{exception} via the response channel" do
            channel = dispatcher.requests[123][:channel]
            task = Async do
              expect { channel.dequeue }.to raise_error(exception)
            end
            subject
            task.wait
          end

          it "closes the response channel" do
            channel = dispatcher.requests[123][:channel]
            expect { subject }.to change(channel, :closed?).from(false).to(true)
          end

          it "removes the request" do
            expect { subject }.to change { dispatcher.requests[123] }.from(Hash).to(nil)
          end
        end

        context "when status is 500" do
          let(:response) { { requestId: 123, status: { code: 500, message: message } } }

          context "when vertex already exists" do
            let(:message) { "Vertex with id already exists: 1234" }

            include_examples "sends an exception via the response channel", Grumlin::VertexAlreadyExistsError
          end

          context "when edge already exists" do
            let(:message) { "Edge with id already exists: 1234" }

            include_examples "sends an exception via the response channel", Grumlin::EdgeAlreadyExistsError
          end

          context "when concurrent vertex insert failed" do
            let(:message) { "Failed to complete Insert operation for a Vertex due to conflicting concurrent" }

            include_examples "sends an exception via the response channel", Grumlin::ConcurrentVertexInsertFailedError
          end

          context "when concurrent edge insert failed" do
            let(:message) { "Failed to complete Insert operation for an Edge due to conflicting concurrent" }

            include_examples "sends an exception via the response channel", Grumlin::ConcurrentEdgeInsertFailedError
          end
        end

        context "when status is 499" do
          context "when status is 499" do
            let(:response) { { requestId: 123, status: { code: 499, message: "" } } }

            include_examples "sends an exception via the response channel", Grumlin::InvalidRequestArgumentsError
          end
        end

        context "when status is 597" do
          let(:response) { { requestId: 123, status: { code: 597, message: "" } } }

          include_examples "sends an exception via the response channel", Grumlin::ScriptEvaluationError
        end

        context "when status is 599" do
          let(:response) { { requestId: 123, status: { code: 599, message: "" } } }

          include_examples "sends an exception via the response channel", Grumlin::ServerSerializationError
        end

        context "when status is 598" do
          let(:response) { { requestId: 123, status: { code: 598, message: "" } } }

          include_examples "sends an exception via the response channel", Grumlin::ServerTimeoutError
        end

        context "when status is 401" do
          let(:response) { { requestId: 123, status: { code: 401, message: "" } } }

          include_examples "sends an exception via the response channel", Grumlin::ClientSideError
        end

        context "when status is 407" do
          let(:response) { { requestId: 123, status: { code: 407, message: "" } } }

          include_examples "sends an exception via the response channel",  Grumlin::ClientSideError
        end

        context "when status is 498" do
          let(:response) { { requestId: 123, status: { code: 498, message: "" } } }

          include_examples "sends an exception via the response channel", Grumlin::ClientSideError
        end
      end
    end

    context "when request is unknown" do
      let(:response) { { requestId: 123 } }

      include_examples "raises an exception", described_class::UnknownRequestError
    end
  end

  describe "#ongoing_request?" do
    subject { dispatcher.ongoing_request?(123) }

    context "when request is ongoing" do
      before do
        dispatcher.add_request({ requestId: 123 })
      end

      include_examples "returns true"
    end

    context "when request is unknown" do
      include_examples "returns false"
    end
  end

  describe "#clear" do
    subject { dispatcher.clear }

    before do
      dispatcher.add_request({ requestId: 123 })
      dispatcher.add_request({ requestId: 124 })
    end

    it "sends errors to all channels" do
      tasks = [123, 124].map do |id|
        channel = dispatcher.requests[id][:channel]
        Async do
          expect { channel.dequeue }.to raise_error(Async::Channel::ChannelClosedError, "Channel was forcefully closed")
        end
      end
      subject
      tasks.each(&:wait)
    end

    it "closes all channels" do
      channels = [123, 124].map do |id|
        dispatcher.requests[id][:channel]
      end
      expect(channels).to all(be_open)
      subject
      expect(channels).to all(be_closed)
    end

    it "clears requests" do
      expect { subject }.to change { dispatcher.requests.empty? }.from(false).to(true)
    end
  end
end
