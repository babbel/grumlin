# frozen_string_literal: true

RSpec.shared_examples "raises an exception" do |exception, message|
  it "raises #{exception.name}" do
    expect { subject }.to raise_error(exception, message)
  end
end

RSpec.shared_examples "raises TypeError" do |message|
  include_examples "raises an exception", TypeError, message
end

RSpec.shared_examples "returns an exception" do |exception, message|
  it "returns an instance of #{exception.name}" do
    expect(subject).to be_an_instance_of(exception)
    expect(subject.message).to eq(message) if message
  end
end
