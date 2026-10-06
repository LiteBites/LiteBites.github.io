#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class KnowledgeGraphTopicTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_generic_inferred_topics_do_not_link_unrelated_bites
    Dir.mktmpdir("knowledge-graph-topic-test") do |dir|
      FileUtils.mkdir_p(File.join(dir, "scripts"))
      FileUtils.cp(File.join(ROOT, "scripts", "generate_knowledge_graph.rb"), File.join(dir, "scripts"))
      FileUtils.mkdir_p(File.join(dir, "_posts"))
      FileUtils.mkdir_p(File.join(dir, "_articles"))
      FileUtils.mkdir_p(File.join(dir, "_datasets"))

      fixtures = {
        "novalad" => ["NovaLAD", "Document Parsing", "Retrieval-Augmented Generation", "Image extraction for generative AI and RAG."],
        "controlnet" => ["ControlNet", "Diffusion Models", "Generative Models", "Visual image generation with diffusion."],
        "rag" => ["Retrieval-Augmented Generation", "Retrieval-Augmented Generation", "Dense Retrieval", "Retrieval for generative AI systems."],
        "qwenwork" => ["QwenWork", "Workplace Agents", "Collaboration", "Multimodal AI for assistants."],
        "chain-of-zoom" => ["Chain-of-Zoom", "Video Editing", "Image Processing", "Multimodal AI for video."],
        "dora" => ["DoRA", "Parameter-Efficient Fine-Tuning", "Adapters", "Efficient adaptation of model weights."],
        "pagedattention" => ["PagedAttention", "LLM Serving", "Memory Management", "Efficient serving of language models."],
        "dreambooth" => ["DreamBooth", "Personalization", "Diffusion Models", "Adaptation for image generation."],
        "vision-a" => ["Vision A", "Computer Vision", "Document Parsing", "Document reading."],
        "vision-b" => ["Vision B", "Computer Vision", "Medical Imaging", "Clinical images."]
      }
      fixtures.each do |slug, (title, first_tag, second_tag, summary)|
        File.write(File.join(dir, "_posts", "2026-10-06-#{slug}.md"), <<~POST)
          ---
          title: "#{title}"
          short_title: "#{title}"
          date: 2026-10-06
          venue: "Preprint"
          read_time: "5 min read"
          summary: "#{summary}"
          tags:
            - #{first_tag}
            - #{second_tag}
          ---
          ## Links
        POST
      end

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, File.join(dir, "scripts", "generate_knowledge_graph.rb"))
      assert status.success?, "graph generation failed: #{stdout}#{stderr}"
      graph = JSON.parse(File.read(File.join(dir, "assets", "data", "knowledge-graph.json")))
      edges = graph.fetch("edges").map { |edge| edge.fetch("id") }
      refute_includes edges, "paper:controlnet|paper:novalad", "unrelated papers should not connect solely via inferred generic topics"
      assert_includes edges, "paper:novalad|paper:rag", "a directly shared specific topic should still connect"
      refute_includes edges, "paper:chain-of-zoom|paper:qwenwork", "inferred Multimodal AI alone is too broad"
      refute_includes edges, "paper:dora|paper:pagedattention", "inferred Efficient AI alone is too broad"
      refute_includes edges, "paper:dora|paper:dreambooth", "inferred Transfer & Adaptation alone is too broad"
      assert_includes edges, "paper:vision-a|paper:vision-b", "two explicitly shared broad tags remain a valid topical link"
    end
  end
end
