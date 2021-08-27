# frozen_string_literal: true

FactoryBot.define do
  factory :edge, class: "Grumlin::Edge" do
    initialize_with { new(**attributes) }

    label { "test_edge" }
    sequence(:id)
    inVLabel { "test_vertex" }
    outVLabel { "test_vertex" }
    sequence(:inV)
    sequence(:outV)
  end
end
