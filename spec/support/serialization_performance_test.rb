# frozen_string_literal: true

class SerializationPerformanceTest
  TYPES = {
    "string" => :to_s,
    "int" => :to_i,
    "double" => :to_f
  }.freeze

  extend Grumlin::Repository

  def initialize(graphml)
    @graphml = Nokogiri::XML(graphml)
  end

  # TODO: make it concurrent
  def import!
    import_nodes!
    import_edges!
  rescue StandardError => _e
    pp "ERROR"
    # binding.irb
  end

  private

  def import_nodes!
    nodes.each_slice(100) do |slice|
      t = g
      slice.each do |node|
        t = t.addV(node[:label]).property(T.id, node[:id])
        t.props(node[:properties])
      end
      t.bytecode.serialize
    end
  end

  def import_edges! # rubocop:disable Metrics/AbcSize
    edges.each_slice(100) do |slice|
      t = g
      slice.each do |edge|
        label = edge[:label]

        t = t.addE(label).property(T.id, edge[:id])
             .from(__.V(edge[:from]))
             .to(__.V(edge[:to]))
        t.props(edge[:properties])
      end
      t.bytecode.serialize
    end
  end

  def nodes # rubocop:disable Metrics/AbcSize
    @nodes ||= begin
      ary = @graphml.xpath("//xmlns:graphml//xmlns:graph//xmlns:node").map do |node|
        {
          label: node.xpath("xmlns:data[@key='labelV']").text,
          id: node.attributes["id"].value.to_i,
          properties: node.xpath("xmlns:data[not(@key='labelV')]").each_with_object({}) do |attribute, result|
            key = attribute.attributes["key"].value
            cast_method = TYPES[properties[:node][key][0][:type]]
            result[key] = attribute.text.public_send(cast_method)
          end
        }
      end
      ary.sample(ary.count / 10)
    end
  end

  def edges # rubocop:disable Metrics/AbcSize
    @edges ||= begin
      ary = @graphml.xpath("//xmlns:graphml//xmlns:graph//xmlns:edge").map do |edge|
        {
          label: edge.xpath("xmlns:data[@key='labelE']").text,
          id: edge.attributes["id"].value.to_i,
          from: edge.attributes["source"].value.to_i,
          to: edge.attributes["target"].value.to_i,
          properties: edge.xpath("xmlns:data[not(@key='labelE')]").each_with_object({}) do |attribute, result|
            key = attribute.attributes["key"].value
            cast_method = TYPES[properties[:edge][key][0][:type]]

            result[key] = attribute.text.public_send(cast_method)
          end
        }
      end
      ary.sample(ary.count / 1000)
    end
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
