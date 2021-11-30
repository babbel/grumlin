# frozen_string_literal: true

RSpec.describe Grumlin::Repository, gremlin_server: true do
  let(:repository) do
    Class.new do
      extend Grumlin::Repository
    end.new
  end

  it "works" do
    p repository.g.V.props(a: 1, b: 1)
    p repository.g.V.hasAll(a: 1, b: 1)
  end
end
