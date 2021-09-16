# frozen_string_literal: true

class GraphMLImporter
  TYPES = {
    "string" => :to_s,
    "int" => :to_i,
    "double" => :to_f
  }.freeze

  include Grumlin::Sugar

  def initialize(graphml)
    @graphml = Nokogiri::XML(graphml)
  end

  # TODO: make it concurrent
  def import!
    import_nodes!
    import_edges!
  end

  private

  def import_nodes! # rubocop:disable Metrics/AbcSize
    nodes.each_slice(100) do |slice|
      t = g
      slice.each do |node|
        label = node.xpath("xmlns:data[@key='labelV']").text

        t = t.addV(label).property(T.id, node.attributes["id"].value.to_i)
        node.xpath("xmlns:data[not(@key='labelV')]").each do |attribute|
          key = attribute.attributes["key"].value
          cast_method = TYPES[properties[:node][key][0][:type]]
          t = t.property(key, attribute.text.send(cast_method))
        end
      end
      t.iterate
    end
  end

  def import_edges! # rubocop:disable Metrics/AbcSize
    edges.each_slice(100) do |slice|
      t = g
      slice.each do |edge|
        label = edge.xpath("xmlns:data[@key='labelE']").text

        t = t.addE(label).property(T.id, edge.attributes["id"].value.to_i)
             .from(__.V(edge.attributes["source"].value.to_i))
             .to(__.V(edge.attributes["target"].value.to_i))
        edge.xpath("xmlns:data[not(@key='labelE')]").each do |attribute|
          key = attribute.attributes["key"].value
          cast_method = TYPES[properties[:edge][key][0][:type]]
          t = t.property(key, attribute.text.send(cast_method))
        end
      end
      t.iterate
    end
  end

  def nodes
    @graphml.xpath("//xmlns:graphml//xmlns:graph//xmlns:node")
  end

  def edges
    @graphml.xpath("//xmlns:graphml//xmlns:graph//xmlns:edge")
  end

  def properties # rubocop:disable Metrics/AbcSize
    @properties ||= @graphml.xpath("//xmlns:graphml//xmlns:key").map do |prop|
      {
        id: prop.attributes["id"].value,
        name: prop.attributes["attr.name"].value,
        type: prop.attributes["attr.type"].value,
        for: prop.attributes["for"].value
      }
    end.group_by { |p| p[:for] }.transform_values { |v| v.group_by { |p| p[:id] } }.symbolize_keys
  end
end
