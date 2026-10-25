#!/usr/bin/env ruby
# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8

require "minitest/autorun"
require "yaml"

# Source-level guards for the shared layout and interactive components.
# Rendered behavior is covered by `scripts/litebites build` + check_site.rb.
class SiteComponentsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def read(relative)
    File.read(File.join(ROOT, relative))
  end

  def test_layout_lets_seo_tag_emit_page_titles
    layout = read("_layouts/default.html")
    refute_match(/<title>/, layout, "a hard-coded <title> gives every page the same title")
    assert_includes layout, "{% seo %}"
  end

  # The theme script binds to the first .theme-toggle; a second one breaks it.
  def test_single_theme_toggle
    assert_equal 1, read("_layouts/default.html").scan(/class="theme-toggle[" ]/).length
  end

  def test_bite_layouts_render_shared_components
    %w[post article].each do |layout|
      source = read("_layouts/#{layout}.html")
      assert_includes source, "include check-yourself.html", "#{layout} layout"
      assert_includes source, "include related-bites.html", "#{layout} layout"
      assert_includes source, "include claim-toggle.html", "#{layout} layout"
    end
    assert_includes read("_layouts/dataset.html"), "include related-bites.html"
    assert_includes read("_layouts/default.html"), "include search.html"
    assert_includes read("_layouts/default.html"), "/assets/js/site.js"
  end

  def test_components_are_documented
    guide = read("_includes/AGENTS.md")
    Dir[File.join(ROOT, "_includes", "*.html")].each do |path|
      name = File.basename(path)
      next if name == "claim-toggle.html" # documented with claim.html

      assert_includes guide, name, "_includes/AGENTS.md must document #{name}"
    end
  end

  def test_repository_documents_are_excluded_from_the_build
    excluded = YAML.safe_load(read("_config.yml")).fetch("exclude")
    Dir.glob("**/AGENTS.md", base: ROOT).each do |path|
      next if excluded.any? { |entry| path.start_with?("#{entry}/") }

      assert_includes excluded, path, "add #{path} to _config.yml exclude"
    end
    %w[POLICY_*.md docs .hermes scripts].each { |entry| assert_includes excluded, entry }
  end
end
