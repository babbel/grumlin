# frozen_string_literal: true

RSpec.describe Async::Channel, async: true do
  let(:channel) { described_class.new }

  describe "#<<" do
    subject { channel << "test" }

    context "when the channel is not closed" do
      it "sends the payload" do
        subject
        expect(channel.dequeue).to eq("test")
      end
    end

    context "when the channel is closed" do
      before { channel.close }

      include_examples "raises an exception", described_class::ChannelClosedError
    end
  end

  describe "#exception" do
    context "when the channel is not closed" do
      it "raises ExceptionReceivedError on #dequeue" do
        channel.exception(Grumlin::Error.new)
        expect { channel.dequeue }.to raise_error(Grumlin::Error)
      end
    end

    context "when the channel is closed" do
      before { channel.close }

      it "raises ChannelClosedError" do
        expect { channel << "test" }.to raise_error(described_class::ChannelClosedError)
      end
    end
  end

  describe "#close" do
    subject { channel.close }

    context "when the channel is not closed" do
      it "closes the channel" do
        expect { subject }.to change(channel, :closed?).from(false).to(true)
      end
    end

    context "when channel is closed" do
      before do
        channel.close
      end

      it "does nothing" do
        expect { subject }.not_to change(channel, :closed?)
      end
    end
  end

  describe "#close!" do
    subject { channel.close! }

    context "when the channel is not closed" do
      it "closes the channel" do
        expect { subject }.to change(channel, :closed?).from(false).to(true)
      end

      it "sends ChannelClosedError via the channel" do
        task = Async do
          expect { channel.dequeue }.to raise_error(Async::Channel::ChannelClosedError, "Channel was forcefully closed")
        end
        subject
        task.wait
      end
    end

    context "when channel is closed" do
      before do
        channel.close
      end

      it "does nothing" do
        expect { subject }.not_to change(channel, :closed?)
      end
    end
  end

  describe "#each" do
    context "when the channel is not closed" do
      it "yields received payload" do
        messages = %w[test1 test2 test3]

        Async do
          n = 0
          channel.each do |msg|
            expect(msg).to eq(message[n])
            n += 1
          end
          expect(channel).to be_closed
        end

        messages.each do |msg|
          channel << msg
        end
        channel.close
      end
    end

    context "when the channel is closed" do
      before { channel.close }

      it "raises ChannelClosedError" do
        expect { channel.each { |_p| } }.to raise_error(described_class::ChannelClosedError) # rubocop:disable Lint/EmptyBlock
      end
    end
  end
end
