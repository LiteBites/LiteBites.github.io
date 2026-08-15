#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "digest"
require "fileutils"
require "json"
require "set"
require "yaml"

ROOT = File.expand_path("..", __dir__)
OUTPUT = File.join(ROOT, "assets", "data", "knowledge-graph.json")
STATE = File.join(ROOT, "_data", "knowledge-graph-state.json")
CURATED = File.join(ROOT, "_data", "knowledge-graph-relations.yml")
SCHEMA_VERSION = 1
GENERATOR_VERSION = 2
MAX_INFERRED_NEIGHBORS = 4

CONCEPT_RULES = {
  "Anomaly Detection" => [/anomal/i, /defect/i],
  "Computer Vision" => [/computer vision/i, /visual/i, /image/i, /vision transformer/i],
  "Datasets" => [/\bdataset/i, /benchmark/i],
  "Diffusion Models" => [/diffusion/i, /dreambooth/i, /controlnet/i],
  "Efficient AI" => [/efficient/i, /serving/i, /memory management/i, /low-rank/i, /small language model/i],
  "Generative AI" => [/generation/i, /generative/i, /text-to-image/i, /video editing/i],
  "Industrial AI" => [/industrial/i, /manufactur/i, /inspection/i, /surface defect/i],
  "Language Models" => [/language model/i, /\bllm/i, /agentic ai/i],
  "Multimodal AI" => [/multimodal/i, /vision-language/i, /audio generation/i],
  "Transfer & Adaptation" => [/transfer learning/i, /fine.?tun/i, /adaptation/i, /personalization/i]
}.freeze

GENERIC_TOPICS = Set.new(["Computer Vision", "Generative AI", "Language Models", "Datasets"]).freeze


def front_matter(path)
  source = File.read(path, encoding: "UTF-8")
  match = source.match(/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m)
  raise "Missing YAML front matter: #{path}" unless match

  data = YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
  [data, source]
end


def slug_for(path, type)
  name = File.basename(path, ".md")
  type == "paper" ? name.sub(/^\d{4}-\d{2}-\d{2}-/, "") : name
end


def clean_list(value)
  Array(value).flatten.compact.map(&:to_s).map(&:strip).reject(&:empty?).uniq
end


def node_from(path, type)
  data, source = front_matter(path)
  slug = slug_for(path, type)
  direct_topics = if type == "paper"
                    clean_list(data["tags"])
                  else
                    clean_list([data["domain"], data["task"]])
                  end
  searchable = [
    data["title"], data["short_title"], data["summary"], data["domain"], data["task"],
    data["use_for"], direct_topics.join(" ")
  ].compact.join(" ")
  concepts = CONCEPT_RULES.filter_map do |topic, patterns|
    topic if patterns.any? { |pattern| searchable.match?(pattern) }
  end

  topics = (direct_topics + concepts).uniq.sort
  topic_weights = topics.to_h do |topic|
    [topic, direct_topics.include?(topic) ? 3 : 1]
  end

  date = data["date"]
  date = date.strftime("%Y-%m-%d") if date.respond_to?(:strftime)

  {
    "id" => "#{type}:#{slug}",
    "slug" => slug,
    "type" => type,
    "title" => data.fetch("title"),
    "shortTitle" => data["short_title"] || data.fetch("title"),
    "url" => type == "paper" ? "/posts/#{slug}/" : "/data/#{slug}/",
    "summary" => data["summary"].to_s,
    "date" => date,
    "meta" => type == "paper" ? [data["venue"], data["read_time"]].compact.join(" / ") : [data["domain"], data["task"]].compact.join(" / "),
    "topics" => topics,
    "topicWeights" => topic_weights,
    "sourceHash" => Digest::SHA256.hexdigest(source),
    "sourcePath" => path.delete_prefix("#{ROOT}/")
  }
end


def inferred_edge(left, right)
  shared = left["topics"] & right["topics"]
  return nil if shared.empty?

  score = shared.sum do |topic|
    [left["topicWeights"].fetch(topic, 1), right["topicWeights"].fetch(topic, 1)].min
  end
  score += 1 if left["type"] != right["type"]
  meaningful = shared.any? { |topic| !GENERIC_TOPICS.include?(topic) }
  return nil if score < 2 && !meaningful

  source, target = [left["id"], right["id"]].sort
  {
    "id" => "#{source}|#{target}",
    "source" => source,
    "target" => target,
    "relation" => "shared-topic",
    "label" => shared.sort.join(" · "),
    "topics" => shared.sort,
    "weight" => score,
    "provenance" => "metadata"
  }
end


def curated_edges(valid_ids)
  return [] unless File.exist?(CURATED)

  document = YAML.safe_load(File.read(CURATED, encoding: "UTF-8"), aliases: true) || {}
  Array(document["relations"]).map do |relation|
    source = relation.fetch("source")
    target = relation.fetch("target")
    source = "paper:#{source}" unless source.include?(":")
    target = "paper:#{target}" unless target.include?(":")
    unless valid_ids.include?(source) && valid_ids.include?(target)
      raise "Curated graph relation references a missing node: #{source} -> #{target}"
    end

    ordered = [source, target].sort
    {
      "id" => "#{ordered[0]}|#{ordered[1]}|#{relation.fetch('relation')}",
      "source" => source,
      "target" => target,
      "relation" => relation.fetch("relation"),
      "label" => relation["label"] || relation.fetch("relation").tr("-", " "),
      "topics" => clean_list(relation["topics"]),
      "weight" => Integer(relation.fetch("weight", 5)),
      "provenance" => "curated"
    }
  end
end


def top_edges(edges)
  ranked = Hash.new { |hash, key| hash[key] = [] }
  edges.each do |edge|
    ranked[edge["source"]] << edge
    ranked[edge["target"]] << edge
  end

  keep = Set.new
  ranked.each_value do |node_edges|
    curated, inferred = node_edges.partition { |edge| edge["provenance"] == "curated" }
    curated.each { |edge| keep << edge["id"] }
    inferred.sort_by { |edge| [-edge["weight"], edge["id"]] }
            .first(MAX_INFERRED_NEIGHBORS)
            .each { |edge| keep << edge["id"] }
  end
  edges.select { |edge| keep.include?(edge["id"]) }
end

existing = if File.exist?(STATE)
             JSON.parse(File.read(STATE, encoding: "UTF-8"))
           else
             {}
           end
existing_nodes = Array(existing["nodes"]).to_h { |node| [node["sourcePath"], node] }
existing_edges = Array(existing["edges"])
compatible = existing["schemaVersion"] == SCHEMA_VERSION && existing["generatorVersion"] == GENERATOR_VERSION

sources = Dir.glob(File.join(ROOT, "_posts", "*.md")).sort.map { |path| [path, "paper"] } +
          Dir.glob(File.join(ROOT, "_datasets", "*.md")).sort.map { |path| [path, "dataset"] }

nodes = []
changed_ids = Set.new
sources.each do |path, type|
  relative = path.delete_prefix("#{ROOT}/")
  hash = Digest::SHA256.file(path).hexdigest
  cached = compatible ? existing_nodes[relative] : nil
  if cached && cached["sourceHash"] == hash
    nodes << cached
  else
    node = node_from(path, type)
    nodes << node
    changed_ids << node["id"]
  end
end

nodes.sort_by! { |node| [node["type"], node["title"].downcase] }
valid_ids = nodes.map { |node| node["id"] }.to_set
removed_ids = Array(existing["nodes"]).map { |node| node["id"] }.to_set - valid_ids
changed_ids.merge(removed_ids)
changed_ids.merge(valid_ids) unless compatible

edges = existing_edges.select do |edge|
  valid_ids.include?(edge["source"]) && valid_ids.include?(edge["target"]) &&
    !changed_ids.include?(edge["source"]) && !changed_ids.include?(edge["target"]) &&
    edge["provenance"] != "curated"
end

index = Hash.new { |hash, key| hash[key] = Set.new }
nodes.each { |node| node["topics"].each { |topic| index[topic] << node["id"] } }
by_id = nodes.to_h { |node| [node["id"], node] }

changed_ids.each do |id|
  node = by_id[id]
  next unless node

  candidates = node["topics"].each_with_object(Set.new) { |topic, set| set.merge(index[topic]) }
  candidates.delete(id)
  candidates.each do |candidate_id|
    edge = inferred_edge(node, by_id.fetch(candidate_id))
    edges << edge if edge
  end
end

edges.concat(curated_edges(valid_ids))
edges = edges.uniq { |edge| edge["id"] }
edges = top_edges(edges).sort_by { |edge| [edge["source"], edge["target"], edge["relation"]] }

stats = {
  "nodes" => nodes.length,
  "edges" => edges.length,
  "papers" => nodes.count { |node| node["type"] == "paper" },
  "datasets" => nodes.count { |node| node["type"] == "dataset" }
}

state = {
  "schemaVersion" => SCHEMA_VERSION,
  "generatorVersion" => GENERATOR_VERSION,
  "nodes" => nodes,
  "edges" => edges,
  "stats" => stats
}

public_nodes = nodes.map do |node|
  node.reject { |key, _value| ["sourceHash", "sourcePath", "topicWeights"].include?(key) }
end
output = {
  "schemaVersion" => SCHEMA_VERSION,
  "generatorVersion" => GENERATOR_VERSION,
  "nodes" => public_nodes,
  "edges" => edges,
  "stats" => stats
}

FileUtils.mkdir_p(File.dirname(OUTPUT))
FileUtils.mkdir_p(File.dirname(STATE))
state_serialized = JSON.pretty_generate(state) + "\n"
output_serialized = JSON.pretty_generate(output) + "\n"
state_changed = !File.exist?(STATE) || File.read(STATE, encoding: "UTF-8") != state_serialized
output_changed = !File.exist?(OUTPUT) || File.read(OUTPUT, encoding: "UTF-8") != output_serialized
File.write(STATE, state_serialized) if state_changed
File.write(OUTPUT, output_serialized) if output_changed

if state_changed || output_changed
  puts "Knowledge graph updated: #{nodes.length} nodes, #{edges.length} edges, #{changed_ids.length} changed sources."
else
  puts "Knowledge graph is current: #{nodes.length} nodes, #{edges.length} edges, 0 changed sources."
end
