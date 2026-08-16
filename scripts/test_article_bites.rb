#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

class ArticleBitesSiteTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def read(relative)
    File.read(File.join(ROOT, relative), encoding: "UTF-8")
  end

  def test_article_collection_layout_index_and_navigation_order
    config = YAML.safe_load(read("_config.yml"), aliases: true)
    articles = config.fetch("collections").fetch("articles")
    assert_equal true, articles.fetch("output")
    assert_equal "/articles/:name/", articles.fetch("permalink")

    assert File.file?(File.join(ROOT, "_layouts", "article.html")), "article layout is missing"
    assert File.file?(File.join(ROOT, "articles.html")), "article index is missing"

    layout = read("_layouts/default.html")
    article_position = layout.index(">Article Bites<")
    paper_position = layout.index(">Paper Bites<")
    data_position = layout.index(">Data Bites<")

    refute_nil article_position, "Article Bites navigation is missing"
    assert_operator article_position, :<, paper_position
    assert_operator paper_position, :<, data_position
  end

  def test_article_policy_index_and_homepage_are_present
    assert File.file?(File.join(ROOT, "POLICY_ARTICLE.md")), "Article Bite policy is missing"

    policy = read("POLICY_ARTICLE.md")
    %w[What\ happened Why\ it\ matters Technical\ context What\ remains\ uncertain Practical\ takeaways Sources].each do |heading|
      assert_includes policy, heading
    end
    assert_includes policy, "400–800"

    index = read("articles.html")
    assert_includes index, 'site.articles | sort: "date" | reverse'
    assert_includes index, "article.source_name"
    assert_includes index, "The first Article Bite is being prepared."

    home = read("index.html")
    article_position = home.index("Latest Article Bites")
    paper_position = home.index("Latest Paper Bites")
    refute_nil article_position, "homepage Article Bites section is missing"
    assert_operator article_position, :<, paper_position
  end

  def test_article_validator_accepts_valid_content_and_rejects_short_content
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    assert File.file?(validator), "Article Bite validator is missing"

    Dir.mktmpdir("article-bites-test") do |dir|
      valid = File.join(dir, "valid.md")
      short = File.join(dir, "short.md")
      File.write(valid, article_fixture(Array.new(410, "evidence").join(" ")))
      File.write(short, article_fixture("Too short to satisfy the editorial contract."))

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, valid)
      assert status.success?, "valid fixture failed: #{stdout}#{stderr}"
      assert_includes stdout, "PASS"

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, short)
      refute status.success?, "short fixture unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "400"
    end
  end

  def test_graph_generator_emits_article_nodes
    Dir.mktmpdir("article-graph-test") do |dir|
      %w[scripts _posts _datasets].each do |entry|
        FileUtils.cp_r(File.join(ROOT, entry), File.join(dir, entry))
      end
      FileUtils.mkdir_p(File.join(dir, "_data"))
      FileUtils.cp(File.join(ROOT, "_data", "knowledge-graph-relations.yml"), File.join(dir, "_data"))
      FileUtils.mkdir_p(File.join(dir, "_articles"))
      article_content = article_fixture(Array.new(410, "evidence").join(" "))
        .sub("  - Testing", "  - Agentic AI")
        .sub(
          'summary: "A complete test summary that explains why the source matters."',
          'summary: "A benchmark release with an intentionally narrow metadata topic."'
        )
      File.write(File.join(dir, "_articles", "test-bite.md"), article_content)

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, File.join(dir, "scripts", "generate_knowledge_graph.rb"))
      assert status.success?, "graph generator failed: #{stdout}#{stderr}"
      graph = JSON.parse(File.read(File.join(dir, "assets", "data", "knowledge-graph.json")))
      article = graph.fetch("nodes").find { |node| node["id"] == "article:test-bite" }
      refute_nil article, "graph did not emit article:test-bite"
      assert_equal "/articles/test-bite/", article.fetch("url")
      assert_equal ["Agentic AI"], article.fetch("topics"), "Article topics must come from reviewed tags only"
      assert_equal 1, graph.fetch("stats").fetch("articles")
    end
  end

  def test_graph_frontend_supports_article_bites_in_preferred_order
    page = read("graph.html")
    article_position = page.index('data-graph-type="article"')
    paper_position = page.index('data-graph-type="paper"')
    data_position = page.index('data-graph-type="dataset"')
    refute_nil article_position, "Article graph filter is missing"
    assert_operator article_position, :<, paper_position
    assert_operator paper_position, :<, data_position
    assert_includes page, "legend-article"
    assert_includes page, "Article Bites</a>"

    javascript = read("assets/js/knowledge-graph.js")
    assert_includes javascript, "new Set(['article', 'paper', 'dataset'])"
    assert_includes javascript, "var TYPE_RANK = { article: 0, paper: 1, dataset: 2 };"
    assert_includes javascript, "function typeLabel"
    assert_includes javascript, "svgElement('polygon'"
    assert_includes page, 'class="graph-filter-group" role="group"'
    assert_includes page, 'class="graph-view-controls" role="group"'
  end

  def test_article_validator_rejects_empty_tags
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-tags-test") do |dir|
      path = File.join(dir, "empty-tags.md")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub("tags:\n  - Testing", "tags: []")
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "empty tags unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "tags"
    end
  end

  def test_article_validator_rejects_non_iso_dates
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-date-test") do |dir|
      path = File.join(dir, "bad-date.md")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub('date: "2026-08-16"', 'date: "August 16, 2026"')
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "non-ISO date unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "YYYY-MM-DD"
    end
  end

  def test_article_validator_rejects_extra_level_two_sections
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-section-test") do |dir|
      path = File.join(dir, "extra-section.md")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub("## Sources", "## Extra analysis\n\nNot part of the contract.\n\n## Sources")
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "extra level-two section unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "exactly"
    end
  end

  def test_article_validator_requires_canonical_url_in_sources_section
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-source-test") do |dir|
      path = File.join(dir, "misplaced-source.md")
      content = article_fixture(Array.new(410, "evidence").join(" "))
        .sub("## What happened\n\n", "## What happened\n\nSee https://example.com/source for context.\n\n")
        .sub("[Primary Source](https://example.com/source)", "[Different source](https://example.org/other)")
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "canonical URL outside Sources section unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "Sources section"
    end
  end

  def test_article_validator_rejects_whitespace_and_non_string_metadata
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-metadata-test") do |dir|
      blank_title = File.join(dir, "blank-title.md")
      numeric_tag = File.join(dir, "numeric-tag.md")
      fixture = article_fixture(Array.new(410, "evidence").join(" "))
      File.write(blank_title, fixture.sub('title: "Test Article Bite"', 'title: "   "'))
      File.write(numeric_tag, fixture.sub("  - Testing", "  - 42"))

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, blank_title)
      refute status.success?, "whitespace-only title unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "title"

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, numeric_tag)
      refute status.success?, "numeric tag unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "tags"
    end
  end

  def test_article_validator_rejects_card_image_path_traversal
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-image-test") do |dir|
      path = File.join(dir, "traversal-image.md")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        'summary: "A complete test summary that explains why the source matters."',
        "summary: \"A complete test summary that explains why the source matters.\"\ncard_image: \"/assets/images/articles/../../_config.yml\"\ncard_image_alt: \"Invalid traversal fixture\""
      )
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "card-image path traversal unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "card_image"
    end
  end

  private

  def article_fixture(opening_text)
    <<~MARKDOWN
      ---
      layout: article
      title: "Test Article Bite"
      short_title: "Test Bite"
      date: "2026-08-16"
      type: "Article Bite"
      read_time: "3 min read"
      source_name: "Primary Source"
      source_url: "https://example.com/source"
      source_published: "2026-08-15"
      last_reviewed: "2026-08-16"
      tags:
        - Testing
      summary: "A complete test summary that explains why the source matters."
      ---

      ## What happened

      #{opening_text}

      ## Why it matters

      This matters because the verified behavior has consequences for practitioners.

      ## Technical context

      The relevant technical context connects the source to the implementation.

      ## What remains uncertain

      Independent evaluation and broader deployment evidence remain unavailable.

      ## Practical takeaways

      - Verify the primary source.
      - Distinguish evidence from interpretation.
      - Review uncertainty before deployment.

      ## Sources

      - [Primary Source](https://example.com/source)
    MARKDOWN
  end
end
