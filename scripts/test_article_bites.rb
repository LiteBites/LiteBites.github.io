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

  def test_article_validator_requires_exact_source_link_destination
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    replacements = {
      "visible text only" => "[https://example.com/source](https://example.org/other)",
      "query wrapper" => "[Wrapped source](https://example.org/redirect?target=https://example.com/source)",
      "URL suffix" => "[Near match](https://example.com/source-extra)"
    }

    Dir.mktmpdir("article-bites-exact-source-test") do |dir|
      replacements.each_with_index do |(label, replacement), index|
        path = File.join(dir, "inexact-source-#{index}.md")
        content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
          "[Primary Source](https://example.com/source)",
          replacement
        )
        File.write(path, content)
        stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
        refute status.success?, "#{label} unexpectedly passed exact source validation"
        assert_includes "#{stdout}#{stderr}", "Sources section"
      end
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

  def test_article_validator_accepts_complete_remote_publisher_figure
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-remote-image-valid") do |dir|
      path = File.join(dir, "valid-remote-image.md")
      figure = <<~HTML
        <figure class="remote-publisher-image" data-source-url="https://example.com/source">
          <a href="https://media.example.com/figure.webp">
            <img
              src="https://media.example.com/figure.webp"
              width="1600"
              height="900"
              loading="lazy"
              decoding="async"
              referrerpolicy="no-referrer"
              alt="Diagram showing the verified system components and data flow.">
          </a>
          <figcaption>
            System architecture from the <a href="https://example.com/source">canonical source</a>.
            <a href="https://media.example.com/figure.webp">Open full-resolution image ↗</a>
          </figcaption>
        </figure>
      HTML
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        "## What remains uncertain",
        "#{figure}\n## What remains uncertain"
      )
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      assert status.success?, "complete remote publisher figure failed: #{stdout}#{stderr}"
    end
  end

  def test_article_validator_rejects_unsafe_or_incomplete_remote_images
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    complete = <<~HTML
      <figure class="remote-publisher-image" data-source-url="https://example.com/source">
        <a href="https://media.example.com/figure.webp">
          <img src="https://media.example.com/figure.webp" width="1600" height="900" loading="lazy" decoding="async" referrerpolicy="no-referrer" alt="Descriptive architecture diagram.">
        </a>
        <figcaption>
          Diagram from the <a href="https://example.com/source">canonical source</a>.
          <a href="https://media.example.com/figure.webp">Open full-resolution image ↗</a>
        </figcaption>
      </figure>
    HTML
    cases = {
      "remote Markdown image" => '![Remote diagram](https://media.example.com/figure.webp)',
      "remote Markdown reference image" => "![Remote diagram][figure]\n\n[figure]: https://media.example.com/figure.webp",
      "remote Markdown shortcut reference image" => "![Remote diagram]\n\n[Remote diagram]: https://media.example.com/figure.webp",
      "protocol-relative Markdown image" => '![Remote diagram](//media.example.com/figure.webp)',
      "remote image outside figure" => '<img src="https://media.example.com/figure.webp" width="1600" height="900" loading="lazy" decoding="async" referrerpolicy="no-referrer" alt="Diagram">',
      "unquoted remote image" => complete.sub('src="https://media.example.com/figure.webp"', 'src=https://media.example.com/figure.webp'),
      "entity-encoded remote image" => '<img src="https&#58;//media.example.com/figure.webp">',
      "protocol-relative image" => complete.gsub('https://media.example.com/figure.webp', '//media.example.com/figure.webp'),
      "missing lazy loading" => complete.sub(' loading="lazy"', ""),
      "missing intrinsic width" => complete.sub(' width="1600"', ""),
      "blank alt text" => complete.sub('alt="Descriptive architecture diagram."', 'alt=""'),
      "wrong referrer policy" => complete.sub('referrerpolicy="no-referrer"', 'referrerpolicy="origin"'),
      "missing source link" => complete.sub('<a href="https://example.com/source">canonical source</a>', 'canonical source'),
      "missing full-resolution caption link" => complete.sub('<a href="https://media.example.com/figure.webp">Open full-resolution image ↗</a>', 'Open full-resolution image'),
      "source absent from Sources" => complete.sub(/https:\/\/example\.com\/source/, "https://publisher.example/story"),
      "srcset bypass" => complete.sub(' alt="Descriptive architecture diagram."', ' srcset="https://tracker.example/figure-2x.webp 2x" alt="Descriptive architecture diagram."'),
      "local src with remote srcset" => '<img src="/assets/images/articles/local.png" srcset="https://tracker.example/figure-2x.webp 2x" alt="Local image with remote variant">',
      "second local image in remote figure" => complete.sub('</a>', "</a>\n<img src=\"/assets/images/articles/local.png\" alt=\"Second image\">")
    }

    Dir.mktmpdir("article-bites-remote-image-invalid") do |dir|
      cases.each_with_index do |(label, markup), index|
        path = File.join(dir, "invalid-remote-image-#{index}.md")
        content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
          "## What remains uncertain",
          "#{markup}\n\n## What remains uncertain"
        )
        File.write(path, content)
        stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
        refute status.success?, "#{label} unexpectedly passed"
        assert_includes "#{stdout}#{stderr}", "remote"
      end
    end
  end

  def test_article_validator_rejects_first_party_figure_without_alt_text
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-first-party-image-invalid") do |dir|
      path = File.join(dir, "test-bite.md")
      figure = first_party_figure.sub(' alt="Source-grounded workflow diagram."', "")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        "## What remains uncertain",
        "#{figure}\n## What remains uncertain"
      )
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "first-party figure without alt text unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "first-party"
    end
  end

  def test_article_validator_rejects_first_party_figure_with_active_content
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-first-party-active-content") do |dir|
      path = File.join(dir, "test-bite.md")
      figure = first_party_figure.sub("</figure>", "<script>alert('unsafe')</script>\n</figure>")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        "## What remains uncertain",
        "#{figure}\n## What remains uncertain"
      )
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "first-party figure with active content unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "first-party"
    end
  end

  def test_article_validator_rejects_first_party_figure_outside_article_asset_directory
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-first-party-wrong-directory") do |dir|
      path = File.join(dir, "test-bite.md")
      figure = first_party_figure.gsub(
        "/assets/images/articles/test-bite/figure.svg",
        "/assets/images/articles/other-bite/figure.svg"
      )
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        "## What remains uncertain",
        "#{figure}\n## What remains uncertain"
      )
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "first-party figure outside the Article asset directory unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "first-party"
    end
  end

  def test_article_validator_requires_scroll_region_for_first_party_figure
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-first-party-scroll-region") do |dir|
      path = File.join(dir, "test-bite.md")
      figure = first_party_figure
        .sub(' class="article-figure-scroll"', "")
        .sub(' tabindex="0" role="region" aria-label="Scrollable source-grounded diagram"', "")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        "## What remains uncertain",
        "#{figure}\n## What remains uncertain"
      )
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "first-party figure without a scroll region unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "first-party"
    end
  end

  def test_article_validator_requires_first_party_caption_provenance
    figure = first_party_figure.sub(
      '<a href="https://example.com/source">canonical source</a>',
      "an uncited source"
    )
    with_isolated_first_party_svg(valid_svg, figure: figure) do |isolated_validator, article_path|
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, isolated_validator, article_path)
      refute status.success?, "first-party figure without caption provenance unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "caption must cite"
    end
  end

  def test_article_validator_rejects_incomplete_first_party_image_metadata
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    cases = {
      "width" => ' width="1600"',
      "height" => ' height="900"',
      "lazy loading" => ' loading="lazy"',
      "async decoding" => ' decoding="async"'
    }
    Dir.mktmpdir("article-bites-first-party-metadata") do |dir|
      cases.each do |label, fragment|
        path = File.join(dir, "test-bite.md")
        figure = first_party_figure.sub(fragment, "")
        content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
          "## What remains uncertain",
          "#{figure}\n## What remains uncertain"
        )
        File.write(path, content)
        stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
        refute status.success?, "first-party figure without #{label} unexpectedly passed"
        assert_includes "#{stdout}#{stderr}", "first-party"
      end
    end
  end

  def test_article_validator_rejects_external_fetches_in_first_party_svg
    cases = {
      "external href" => '<svg xmlns="http://www.w3.org/2000/svg"><image href="https://tracker.example/pixel.png"/></svg>',
      "relative CSS url" => '<svg xmlns="http://www.w3.org/2000/svg"><style>.tracked{fill:url(/tracker.svg)}</style><rect class="tracked"/></svg>'
    }
    cases.each do |label, svg|
      with_isolated_first_party_svg(svg) do |validator, article_path|
        stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, article_path)
        refute status.success?, "first-party SVG with #{label} unexpectedly passed"
        assert_includes "#{stdout}#{stderr}", "first-party"
      end
    end
  end

  def test_article_validator_rejects_unwrapped_local_article_image
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    Dir.mktmpdir("article-bites-first-party-unwrapped") do |dir|
      path = File.join(dir, "test-bite.md")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        "## What remains uncertain",
        "![Unwrapped local diagram](/assets/images/articles/test-bite/figure.svg)\n\n## What remains uncertain"
      )
      File.write(path, content)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, path)
      refute status.success?, "unwrapped local Article image unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "first-party"
    end
  end

  def test_article_validator_rejects_active_first_party_svg
    svg = '<svg xmlns="http://www.w3.org/2000/svg" onload="alert(1)"><animate attributeName="opacity"/></svg>'
    with_isolated_first_party_svg(svg) do |validator, article_path|
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, article_path)
      refute status.success?, "active first-party SVG unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "first-party"
    end
  end

  def test_article_validator_rejects_first_party_srcset
    figure = first_party_figure.sub(
      ' src="/assets/images/articles/test-bite/figure.svg"',
      ' src="/assets/images/articles/test-bite/figure.svg" srcset="/assets/images/articles/test-bite/figure.svg 1x"'
    )
    with_isolated_first_party_svg(valid_svg, figure: figure) do |validator, article_path|
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, article_path)
      refute status.success?, "first-party figure with srcset unexpectedly passed"
      assert_includes "#{stdout}#{stderr}", "first-party"
    end
  end

  def test_checked_in_first_party_figures_pass_article_validator
    validator = File.join(ROOT, "scripts", "validate_article_bites.rb")
    paths = %w[
      _articles/gpt-6-astra.md
      _articles/slides-grab.md
    ].map { |relative| File.join(ROOT, relative) }
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, validator, *paths)
    assert status.success?, "checked-in first-party figures failed validation:\n#{stdout}\n#{stderr}"
    assert_includes stdout, "PASS #{paths[0]}"
    assert_includes stdout, "PASS #{paths[1]}"
  end

  private

  def valid_svg
    '<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="900" viewBox="0 0 1600 900"><rect width="1600" height="900"/></svg>'
  end

  def with_isolated_first_party_svg(svg_source, figure: first_party_figure)
    Dir.mktmpdir("article-bites-first-party-svg") do |dir|
      FileUtils.mkdir_p(File.join(dir, "scripts"))
      FileUtils.mkdir_p(File.join(dir, "_articles"))
      FileUtils.mkdir_p(File.join(dir, "assets", "images", "articles", "test-bite"))
      FileUtils.cp(File.join(ROOT, "scripts", "validate_article_bites.rb"), File.join(dir, "scripts"))
      FileUtils.cp(File.join(ROOT, "Gemfile"), dir)
      File.write(File.join(dir, "assets", "images", "articles", "test-bite", "figure.svg"), svg_source)

      article_path = File.join(dir, "_articles", "test-bite.md")
      content = article_fixture(Array.new(410, "evidence").join(" ")).sub(
        "## What remains uncertain",
        "#{figure}\n## What remains uncertain"
      )
      File.write(article_path, content)
      yield File.join(dir, "scripts", "validate_article_bites.rb"), article_path
    end
  end

  def first_party_figure
    <<~HTML
      <figure class="article-figure">
        <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable source-grounded diagram">
          <a href="/assets/images/articles/test-bite/figure.svg">
            <img src="/assets/images/articles/test-bite/figure.svg" width="1600" height="900" loading="lazy" decoding="async" alt="Source-grounded workflow diagram.">
          </a>
        </div>
        <figcaption>
          LiteBites synthesis from the <a href="https://example.com/source">canonical source</a>.
          On narrow screens, swipe horizontally or <a href="/assets/images/articles/test-bite/figure.svg">open full resolution ↗</a>
        </figcaption>
      </figure>
    HTML
  end

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
