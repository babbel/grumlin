# frozen_string_literal: true

RSpec.describe Async::Channel, async: true do
  let(:channel) { described_class.new }

  describe "#<<" do
    context "when the channel is not closed" do
      it "sends the payload" do
        channel << "test"
        expect(channel.dequeue).to eq("test")
      end
    end

    context "when the channel is closed" do
      before { channel.close }

      it "raises ChannelClosedError" do
        expect { channel << "test" }.to raise_error(described_class::ChannelClosedError)
      end
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
    context "when the channel is not closed" do
      it "closes the channel" do
        expect { channel.close }.to change(channel, :closed?).from(false).to(true)
      end
    end
  end

  describe "#each" do
    context "when the channel is not closed" do
      it "yields received payload" do
        messages = %w[test1 test2 test3]

        reactor.async do
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
