# frozen_string_literal: true

# Shared checks used by scripts/validate_bites.rb. Every check raises
# BiteValidationError with a message that says what to fix.
#
# Callers must define ROOT (a Pathname for the repository root) before
# requiring this file.

require "cgi"
require "date"
require "kramdown"
require "kramdown-parser-gfm"
require "nokogiri"
require "uri"
require "yaml"

class BiteValidationError < StandardError; end
# Older name kept for scripts and notes that still reference it.
ArticleValidationError = BiteValidationError

def split_front_matter(content)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
  raise BiteValidationError, "missing YAML front matter" unless match

  metadata = YAML.safe_load(
    match[1],
    permitted_classes: [Date, Time],
    aliases: false
  )
  raise BiteValidationError, "front matter must be a mapping" unless metadata.is_a?(Hash)

  [metadata, match[2]]
rescue Psych::Exception => e
  raise BiteValidationError, "invalid YAML front matter: #{e.message}"
end

def present?(value)
  !value.nil? && (!value.respond_to?(:empty?) || !value.empty?)
end

def non_blank_string?(value)
  value.is_a?(String) && !value.strip.empty?
end

def validate_https_url(value, label)
  uri = URI.parse(value.to_s)
  raise BiteValidationError, "#{label} must use HTTPS" unless uri.is_a?(URI::HTTPS) && present?(uri.host)
rescue URI::InvalidURIError
  raise BiteValidationError, "#{label} is not a valid URL"
end

def parse_date(value, field)
  text = value.is_a?(Date) ? value.iso8601 : value.to_s
  raise BiteValidationError, "#{field} must use YYYY-MM-DD" unless text.match?(/\A\d{4}-\d{2}-\d{2}\z/)

  Date.iso8601(text)
rescue Date::Error
  raise BiteValidationError, "#{field} must use YYYY-MM-DD"
end

def body_word_count(body)
  plain = body
    .gsub(/```.*?```/m, " ")
    .gsub(/`[^`]*`/, " ")
    .gsub(/<[^>]+>/, " ")
    .gsub(/!\[[^\]]*\]\([^)]*\)/, " ")
    .gsub(/\[([^\]]+)\]\([^)]*\)/, "\\1")
    .gsub(/^\#{1,6}\s+.*$/, " ")
    .gsub(%r{https?://\S+}, " ")

  plain.scan(/[\p{L}\p{N}]+(?:[’'\-][\p{L}\p{N}]+)*/u).length
end

def validate_headings(body, final:, min_narrative:)
  headings = body.scan(/^##\s+(.+?)\s*$/).flatten
  narrative_headings = headings.reject { |heading| heading == final }

  if headings.count(final) != 1
    raise BiteValidationError, "body must contain exactly one level-two #{final} section"
  end
  unless headings.last == final
    raise BiteValidationError, "level-two #{final} section must be last"
  end
  if narrative_headings.length < min_narrative
    raise BiteValidationError, "body must contain at least #{min_narrative} narrative level-two sections before #{final}"
  end
  if headings.uniq.length != headings.length
    raise BiteValidationError, "level-two section headings must be unique"
  end
end

def validate_local_image(metadata, path, field:, alt:, dir:)
  image = metadata[field]
  return unless present?(image)

  raise BiteValidationError, "#{field} must be a non-empty string" unless non_blank_string?(image)
  raise BiteValidationError, "#{alt} is required with #{field}" unless non_blank_string?(metadata[alt])
  unless image.start_with?(dir)
    raise BiteValidationError, "#{field} must live under #{dir}"
  end

  allowed_root = ROOT.join(dir.delete_prefix("/")).expand_path
  repository_image = ROOT.join(image.delete_prefix("/")).expand_path
  unless repository_image.to_s.start_with?("#{allowed_root}#{File::SEPARATOR}")
    raise BiteValidationError, "#{field} must not traverse outside #{dir}"
  end
  return if repository_image.file?
  return unless path.expand_path.to_s.start_with?(ROOT.to_s)

  raise BiteValidationError, "#{field} does not exist: #{image}"
end

def validate_additional_sources(metadata)
  sources = metadata["additional_sources"]
  return unless present?(sources)
  raise BiteValidationError, "additional_sources must be a list" unless sources.is_a?(Array)

  sources.each_with_index do |source, index|
    unless source.is_a?(Hash) && non_blank_string?(source["name"]) && non_blank_string?(source["url"])
      raise BiteValidationError, "additional_sources[#{index}] requires name and url"
    end
    validate_https_url(source["url"], "additional_sources[#{index}].url")
  end
end

def rendered_fragment(markdown)
  html = Kramdown::Document.new(markdown, input: "GFM").to_html
  Nokogiri::HTML5.fragment(html)
rescue StandardError => e
  raise BiteValidationError, "body could not be rendered for validation: #{e.message}"
end

def remote_url?(value)
  text = value.to_s.strip
  return true if text.start_with?("//")

  uri = URI.parse(text)
  %w[http https].include?(uri.scheme.to_s.downcase)
rescue URI::InvalidURIError
  false
end

def source_link_destinations(sources_section)
  rendered_fragment(sources_section).css("a[href]").map { |link| link["href"].to_s }.uniq
end

def remote_srcset?(value)
  value.to_s.split(",").any? do |candidate|
    remote_url?(candidate.strip.split(/\s+/, 2).first)
  end
end

def raw_remote_image_count(body)
  review_body = body
    .gsub(/```.*?```/m, " ")
    .gsub(/`[^`]*`/, " ")
    .gsub(/<!--.*?-->/m, " ")
  decoded = CGI.unescapeHTML(review_body)
  decoded.scan(/<img\b[^>]*\bsrc\s*=\s*(?:(["'])(.*?)\1|([^\s>]+))/im).count do |_quote, quoted, unquoted|
    remote_url?(quoted || unquoted)
  end
end

def validate_remote_inline_images(body, source_links)
  document = rendered_fragment(body)

  document.css("img[srcset], source[srcset]").each do |element|
    next unless remote_srcset?(element["srcset"])

    raise BiteValidationError, "remote publisher images must not use img/source srcset variants"
  end

  document.css("source[src]").each do |element|
    next unless remote_url?(element["src"])

    raise BiteValidationError, "remote publisher images must not use source elements"
  end

  remote_images = document.css("img[src]").select { |image| remote_url?(image["src"]) }
  if raw_remote_image_count(body) > remote_images.length
    raise BiteValidationError, "remote image markup must render as an inspectable image element"
  end
  return if remote_images.empty?

  remote_images.each do |image|
    figure = image.ancestors("figure").find { |ancestor| ancestor["class"].to_s.split.include?("remote-publisher-image") }
    unless figure
      raise BiteValidationError, "every remote publisher image must be inside a complete remote-publisher-image figure"
    end

    unless figure.css("img").length == 1
      raise BiteValidationError, "each remote-publisher-image figure must contain exactly one image"
    end
    if figure.at_css("picture, source")
      raise BiteValidationError, "remote-publisher-image figures must not contain picture or source elements"
    end
    if image.key?("srcset")
      raise BiteValidationError, "remote publisher image must not use srcset"
    end

    source_url = figure["data-source-url"]
    unless non_blank_string?(source_url)
      raise BiteValidationError, "remote publisher figure requires data-source-url"
    end
    validate_https_url(source_url, "remote publisher data-source-url")

    image_url = image["src"]
    validate_https_url(image_url, "remote publisher image src")
    unless non_blank_string?(image["alt"])
      raise BiteValidationError, "remote publisher image requires descriptive alt text"
    end
    %w[width height].each do |dimension|
      value = image[dimension]
      unless value.to_s.match?(/\A[1-9]\d*\z/)
        raise BiteValidationError, "remote publisher image requires a positive integer #{dimension}"
      end
    end
    unless image["loading"] == "lazy"
      raise BiteValidationError, "remote publisher image requires loading=\"lazy\""
    end
    unless image["decoding"] == "async"
      raise BiteValidationError, "remote publisher image requires decoding=\"async\""
    end
    unless image["referrerpolicy"] == "no-referrer"
      raise BiteValidationError, "remote publisher image requires referrerpolicy=\"no-referrer\""
    end

    captions = figure.css("figcaption")
    unless captions.length == 1
      raise BiteValidationError, "remote publisher image requires exactly one figcaption"
    end
    caption_links = captions.first.css("a[href]").map { |link| link["href"].to_s }
    unless caption_links.include?(source_url)
      raise BiteValidationError, "remote publisher image caption must link data-source-url"
    end
    unless caption_links.include?(image_url)
      raise BiteValidationError, "remote publisher image caption must link the full-resolution image"
    end
    unless source_links.include?(source_url)
      raise BiteValidationError, "remote publisher data-source-url must be an exact link destination in the final Sources/Links section"
    end
  end
end

def first_party_asset_path(value)
  text = value.to_s.strip
  return text if text.start_with?("/assets/images/articles/")

  match = text.match(%r{\A\{\{\s*['"](?<path>/assets/images/articles/[^'"]+)['"]\s*\|\s*relative_url\s*\}\}\z})
  match && match[:path]
end

def validate_first_party_asset(asset_path)
  article_assets = ROOT.join("assets", "images", "articles").expand_path
  repository_asset = ROOT.join(asset_path.delete_prefix("/")).expand_path
  unless repository_asset.to_s.start_with?("#{article_assets}#{File::SEPARATOR}") && repository_asset.file?
    raise BiteValidationError, "first-party figure asset does not exist under assets/images/articles"
  end
  return unless repository_asset.extname.downcase == ".svg"

  source = repository_asset.read(encoding: "UTF-8")
  document = Nokogiri::XML(source) { |config| config.strict.nonet }
  active_elements = %w[script foreignobject animate animatemotion animatetransform set]
  has_active_element = document.xpath("//*").any? { |node| active_elements.include?(node.name.downcase) }
  attributes = document.xpath("//@*")
  has_event_handler = attributes.any? { |attribute| attribute.name.downcase.start_with?("on") }
  has_javascript_url = attributes.any? { |attribute| attribute.value.to_s.strip.downcase.start_with?("javascript:") }
  if document.internal_subset || has_active_element || has_event_handler || has_javascript_url
    raise BiteValidationError, "first-party SVG must not contain active content"
  end
  external_reference = attributes.any? do |attribute|
    next false unless %w[href src].include?(attribute.name.downcase)

    value = attribute.value.to_s.strip
    !value.empty? && !value.start_with?("#")
  end
  css_references = source.scan(%r{url\s*\(\s*(['"]?)(.*?)\1\s*\)}im).map { |match| match[1].to_s.strip }
  external_style = source.match?(/@import/i) || css_references.any? { |value| !value.empty? && !value.start_with?("#") }
  if external_reference || external_style
    raise BiteValidationError, "first-party SVG must not fetch external resources"
  end
rescue Nokogiri::XML::SyntaxError => e
  raise BiteValidationError, "first-party SVG is invalid XML: #{e.message}"
end

def validate_first_party_inline_figures(body, path, source_links)
  document = rendered_fragment(body)
  document.css("img").each do |image|
    next unless first_party_asset_path(image["src"])
    next if image.ancestors.any? { |ancestor| ancestor.name == "figure" && ancestor["class"].to_s.split.include?("article-figure") }

    raise BiteValidationError, "first-party Article image must be wrapped in figure.article-figure"
  end

  document.css("figure.article-figure").each do |figure|
    if figure.at_css("script, iframe, object, embed, foreignobject")
      raise BiteValidationError, "first-party figure must not contain active or embedded content"
    end

    images = figure.css("img")
    unless images.length == 1
      raise BiteValidationError, "first-party figure must contain exactly one image"
    end
    if figure.at_css("picture, source") || images.any? { |candidate| non_blank_string?(candidate["srcset"]) }
      raise BiteValidationError, "first-party figure must not use picture, source, or srcset"
    end
    image = images.first
    unless image && non_blank_string?(image["alt"])
      raise BiteValidationError, "first-party figure requires descriptive alt text"
    end
    %w[width height].each do |dimension|
      unless image[dimension].to_s.match?(/\A[1-9]\d*\z/)
        raise BiteValidationError, "first-party figure requires a positive integer #{dimension}"
      end
    end
    unless image["loading"] == "lazy" && image["decoding"] == "async"
      raise BiteValidationError, "first-party figure requires loading=\"lazy\" and decoding=\"async\""
    end

    scroll_region = figure.at_css(".article-figure-scroll")
    unless scroll_region && image.ancestors.include?(scroll_region) &&
           scroll_region["tabindex"] == "0" && scroll_region["role"] == "region" &&
           non_blank_string?(scroll_region["aria-label"])
      raise BiteValidationError, "first-party figure requires a labeled keyboard-focusable article-figure-scroll region"
    end

    asset_path = first_party_asset_path(image["src"])
    slug = path.basename(".md").to_s
    unless asset_path&.start_with?("/assets/images/articles/#{slug}/") && !asset_path.split("/").include?("..")
      raise BiteValidationError, "first-party figure image must live under /assets/images/articles/#{slug}/"
    end
    validate_first_party_asset(asset_path)

    captions = figure.css("figcaption")
    unless captions.length == 1 && captions.first.text.include?("LiteBites synthesis")
      raise BiteValidationError, "first-party figure requires one caption labeled LiteBites synthesis"
    end
    caption_links = captions.first.css("a[href]")
    unless caption_links.any? { |link| first_party_asset_path(link["href"]) == asset_path }
      raise BiteValidationError, "first-party figure caption must link the full-resolution asset"
    end
    cited_links = caption_links.map { |link| link["href"].to_s }.select { |href| remote_url?(href) }
    unless cited_links.any? { |href| source_links.include?(href) }
      raise BiteValidationError, "first-party figure caption must cite an exact link destination from Sources"
    end
  end
end
