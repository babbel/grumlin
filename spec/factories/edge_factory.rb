# frozen_string_literal: true

FactoryBot.define do
  factory :edge, class: "Grumlin::Edge" do
    sequence(:id)

    initialize_with { new(**attributes) }

    label { "test_edge" }
    inVLabel { "test_vertex" }
    outVLabel { "test_vertex" }
    sequence(:inV)
    sequence(:outV)
  end
end
