#!/usr/bin/env ruby
# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

# Covers the schema-driven rules that Article-specific tests do not:
# Paper and Data Bites, tag vocabulary, filenames, and component data.
class ValidateBitesTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_checked_in_bites_pass
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "scripts", "validate_bites.rb"))
    assert status.success?, "checked-in Bites failed validation:\n#{stderr}"
    assert_includes stdout, "paper"
    assert_includes stdout, "data"
  end

  # .paper-archive.toml is read by paper tooling; keep it in step with the schema.
  def test_paper_archive_profile_matches_schema
    schema = YAML.safe_load(File.read(File.join(ROOT, "_data", "bite_schema.yml"))).fetch("types").fetch("paper")
    profile = File.read(File.join(ROOT, ".paper-archive.toml"))
    required = profile[/^required = \[(.*?)\]/m, 1].scan(/"([^"]+)"/).flatten
    assert_equal schema.fetch("required").sort, required.sort, "update .paper-archive.toml [metadata].required"
    words = schema.fetch("words")
    assert_includes profile, "min_words = #{words['min']}"
    assert_includes profile, "max_words = #{words['max']}"
  end

  def test_valid_paper_and_data_pass
    with_repo do |dir, run|
      write(dir, "_posts/2026-10-01-test-paper.md", paper_fixture)
      write(dir, "_datasets/test-data.md", data_fixture)
      stdout, stderr, status = run.call
      assert status.success?, "#{stdout}#{stderr}"
    end
  end

  def test_paper_rules
    cases = {
      "date mismatch" => ["_posts/2026-10-02-test-paper.md", paper_fixture, "filename date"],
      "uppercase slug" => ["_posts/2026-10-01-Test-Paper.md", paper_fixture, "kebab-case"],
      "missing Links" => ["_posts/2026-10-01-test-paper.md", paper_fixture.sub("## Links", "## Sources"), "Links"],
      "paper_url not linked" => ["_posts/2026-10-01-test-paper.md", paper_fixture.sub("(https://arxiv.org/abs/1234.5678)", "(https://example.org/other)"), "paper_url"],
      "too short" => ["_posts/2026-10-01-test-paper.md", paper_fixture(words: 100), "900"],
      "unknown field" => ["_posts/2026-10-01-test-paper.md", paper_fixture.sub("venue:", "vneue: x\nvenue:"), "unknown front-matter"],
      "unknown tag" => ["_posts/2026-10-01-test-paper.md", paper_fixture.sub("  - LoRA", "  - Made Up Tag"), "tags.yml"]
    }
    cases.each do |label, (relative, content, expected)|
      with_repo do |dir, run|
        write(dir, relative, content)
        stdout, stderr, status = run.call
        refute status.success?, "#{label} unexpectedly passed"
        assert_includes "#{stdout}#{stderr}", expected, label
      end
    end
  end

  def test_legacy_papers_skip_word_minimum
    with_repo do |dir, run|
      write(dir, "_posts/2025-05-01-test-paper.md", paper_fixture(words: 300, date: "2025-05-01"))
      stdout, stderr, status = run.call
      assert status.success?, "#{stdout}#{stderr}"
    end
  end

  def test_data_requires_image_alt
    with_repo do |dir, run|
      write(dir, "_datasets/test-data.md", data_fixture.sub(/^image_alt:.*\n/, ""))
      stdout, stderr, status = run.call
      refute status.success?
      assert_includes "#{stdout}#{stderr}", "image_alt"
    end
  end

  private

  # Builds a minimal isolated repository so filename and asset rules apply.
  def with_repo
    Dir.mktmpdir("validate-bites-test") do |dir|
      FileUtils.mkdir_p(File.join(dir, "scripts"))
      %w[validate_bites.rb lib].each { |entry| FileUtils.cp_r(File.join(ROOT, "scripts", entry), File.join(dir, "scripts")) }
      FileUtils.mkdir_p(File.join(dir, "_data"))
      %w[bite_schema.yml tags.yml].each { |entry| FileUtils.cp(File.join(ROOT, "_data", entry), File.join(dir, "_data")) }
      FileUtils.cp(File.join(ROOT, "Gemfile"), dir)
      %w[_posts _datasets _articles].each { |entry| FileUtils.mkdir_p(File.join(dir, entry)) }
      FileUtils.mkdir_p(File.join(dir, "assets", "images", "datasets"))
      File.write(File.join(dir, "assets", "images", "datasets", "test-data.jpg"), "x")
      runner = -> { Open3.capture3(RbConfig.ruby, File.join(dir, "scripts", "validate_bites.rb")) }
      yield dir, runner
    end
  end

  def write(dir, relative, content)
    Dir.glob(File.join(dir, File.dirname(relative), "*.md")).each { |path| File.delete(path) }
    File.write(File.join(dir, relative), content)
  end

  def paper_fixture(words: 950, date: "2026-10-01", extra: "", body_extra: "")
    <<~MARKDOWN
      ---
      layout: post
      title: "Test Paper"
      short_title: "Test"
      date: #{date}
      type: "Paper brief"
      read_time: "6 min read"
      venue: "arXiv preprint"
      tags:
        - LoRA
      summary: "A test summary."
      paper_url: "https://arxiv.org/abs/1234.5678"
      #{extra.rstrip}
      ---

      ## Why this paper matters

      #{Array.new(words, 'evidence').join(' ')}

      #{body_extra}

      ## The bite

      Idea.

      ## How it works

      Method.

      ## What to look at in the results

      Results.

      ## Links

      - [Paper](https://arxiv.org/abs/1234.5678)
    MARKDOWN
  end

  def data_fixture
    <<~MARKDOWN
      ---
      title: "Test Data"
      short_title: "Test Data"
      domain: "Vision"
      task: "Classification"
      summary: "A dataset."
      use_for: "tests"
      scale: "10 images"
      license: "CC BY 4.0"
      caveat: "Tiny."
      dataset_url: "https://example.com/data"
      image: "/assets/images/datasets/test-data.jpg"
      image_alt: "Sample grid"
      tags:
        - Benchmark
      ---

      #{Array.new(60, 'context').join(' ')}
    MARKDOWN
  end
end
