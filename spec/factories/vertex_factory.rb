# frozen_string_literal: true

FactoryBot.define do
  factory :vertex, class: "Grumlin::Vertex" do
    sequence(:id)

    initialize_with { new(**attributes) }

    label { "test_vertex" }
  end
end
