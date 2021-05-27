# frozen_string_literal: true

FactoryBot.define do
  factory :vertex, class: "Grumlin::Vertex" do
    initialize_with { Grumlin::Vertex.new(**attributes) } # TODO: find a way to get class from the factory

    label { "test_vertex" }
    sequence(:id)
  end
end
