# frozen_string_literal: true

FactoryBot.define do
  factory :vertex, class: "Grumlin::Vertex" do
    initialize_with { new(**attributes) }

    label { "test_vertex" }
    sequence(:id)
  end
end
