# frozen_string_literal: true

RSpec.shared_examples "raises an exception" do |exception, message|
  it "raises #{exception.name}" do
    expect { subject }.to raise_error(exception, message)
  end
end

RSpec.shared_examples "does not raise" do
  it "does not raise any errors" do
    expect { subject }.not_to raise_error
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

RSpec.shared_examples "returns" do |value|
  it "returns #{value}" do
    expect(subject).to eq(value)
  end
end

RSpec.shared_examples "returns false" do
  include_examples "returns", false
end

RSpec.shared_examples "returns true" do
  include_examples "returns", true
end

RSpec.shared_examples "returns nil" do
  include_examples "returns", nil
end
