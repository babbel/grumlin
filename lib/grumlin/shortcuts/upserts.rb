# frozen_string_literal: true

module Grumlin::Shortcuts::Upserts
  extend Grumlin::Shortcuts

  shortcut :upsertV do |label, id, create_properties = {}, update_properties = {}|
    self.V(id)
        .fold
        .coalesce(
          __.unfold,
          __.addV(label).props(Cardinality.single, **create_properties.merge(T.id => id))
        ).props(Cardinality.single, **update_properties)
  end

  shortcut :upsertE do |label, from, to, create_properties = {}, update_properties = {}|
    id = create_properties[T.id] || Grumlin.fake_uuid(from, label, to)
    self.V(from)
        .outE(label).where(__.inV.hasId(to))
        .fold
        .coalesce(
          __.unfold,
          __.addE(label).from(__.V(from)).to(__.V(to)).props(**create_properties.merge(T.id => id))
        ).props(**update_properties)
  end
end
