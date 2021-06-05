# frozen_string_literal: true

RSpec.describe Grumlin::Transport::Async, clean_db: true do
  let(:url) { "ws://localhost:8182/gremlin" }
  let!(:transport) { described_class.new(url) }

  it "successfully connects and disconnects" do
    transport.connect
    transport.disconnect
  end
end
