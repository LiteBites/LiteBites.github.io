#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "uri"
require "yaml"

REQUIRED_FIELDS = %w[
  layout title short_title date type read_time source_name source_url
  source_published last_reviewed tags summary
].freeze

STRING_FIELDS = %w[
  layout title short_title type read_time source_name source_url summary
].freeze

REQUIRED_HEADINGS = [
  "What happened",
  "Why it matters",
  "Technical context",
  "What remains uncertain",
  "Practical takeaways",
  "Sources"
].freeze

MIN_WORDS = 400
MAX_WORDS = 800
ROOT = Pathname.new(File.expand_path("..", __dir__))

class ArticleValidationError < StandardError; end

def split_front_matter(content)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
  raise ArticleValidationError, "missing YAML front matter" unless match

  metadata = YAML.safe_load(
    match[1],
    permitted_classes: [Date, Time],
    aliases: false
  )
  raise ArticleValidationError, "front matter must be a mapping" unless metadata.is_a?(Hash)

  [metadata, match[2]]
rescue Psych::Exception => e
  raise ArticleValidationError, "invalid YAML front matter: #{e.message}"
end

def present?(value)
  !value.nil? && (!value.respond_to?(:empty?) || !value.empty?)
end

def non_blank_string?(value)
  value.is_a?(String) && !value.strip.empty?
end

def validate_https_url(value, label)
  uri = URI.parse(value.to_s)
  raise ArticleValidationError, "#{label} must use HTTPS" unless uri.is_a?(URI::HTTPS) && present?(uri.host)
rescue URI::InvalidURIError
  raise ArticleValidationError, "#{label} is not a valid URL"
end

def parse_date(value, field)
  text = value.is_a?(Date) ? value.iso8601 : value.to_s
  raise ArticleValidationError, "#{field} must use YYYY-MM-DD" unless text.match?(/\A\d{4}-\d{2}-\d{2}\z/)

  Date.iso8601(text)
rescue Date::Error
  raise ArticleValidationError, "#{field} must use YYYY-MM-DD"
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

def validate_headings(body)
  headings = body.scan(/^##\s+(.+?)\s*$/).flatten
  return if headings == REQUIRED_HEADINGS

  expected = REQUIRED_HEADINGS.map { |heading| "## #{heading}" }.join(" -> ")
  raise ArticleValidationError, "level-two headings must be exactly: #{expected}"
end

def validate_local_image(metadata, path)
  image = metadata["card_image"]
  return unless present?(image)

  raise ArticleValidationError, "card_image must be a non-empty string" unless non_blank_string?(image)

  alt = metadata["card_image_alt"]
  raise ArticleValidationError, "card_image_alt is required with card_image" unless non_blank_string?(alt)
  unless image.start_with?("/assets/images/articles/")
    raise ArticleValidationError, "card_image must live under /assets/images/articles/"
  end

  article_assets = ROOT.join("assets", "images", "articles").expand_path
  repository_image = ROOT.join(image.delete_prefix("/")).expand_path
  unless repository_image.to_s.start_with?("#{article_assets}#{File::SEPARATOR}")
    raise ArticleValidationError, "card_image must not traverse outside /assets/images/articles/"
  end
  return if repository_image.file?
  return unless path.expand_path.to_s.start_with?(ROOT.to_s)

  raise ArticleValidationError, "card_image does not exist: #{image}"
end

def validate_additional_sources(metadata)
  sources = metadata["additional_sources"]
  return unless present?(sources)
  raise ArticleValidationError, "additional_sources must be a list" unless sources.is_a?(Array)

  sources.each_with_index do |source, index|
    unless source.is_a?(Hash) && non_blank_string?(source["name"]) && non_blank_string?(source["url"])
      raise ArticleValidationError, "additional_sources[#{index}] requires name and url"
    end
    validate_https_url(source["url"], "additional_sources[#{index}].url")
  end
end

def validate_article(path)
  metadata, body = split_front_matter(path.read(encoding: "UTF-8"))

  missing = REQUIRED_FIELDS.reject { |field| present?(metadata[field]) }
  raise ArticleValidationError, "missing required fields: #{missing.join(', ')}" unless missing.empty?
  invalid_strings = STRING_FIELDS.reject { |field| non_blank_string?(metadata[field]) }
  unless invalid_strings.empty?
    raise ArticleValidationError, "fields must be non-empty strings: #{invalid_strings.join(', ')}"
  end
  raise ArticleValidationError, "layout must be 'article'" unless metadata["layout"] == "article"
  raise ArticleValidationError, "type must be 'Article Bite'" unless metadata["type"] == "Article Bite"
  valid_tags = metadata["tags"].is_a?(Array) && !metadata["tags"].empty? && metadata["tags"].all? { |tag| non_blank_string?(tag) }
  raise ArticleValidationError, "tags must be a non-empty list of strings" unless valid_tags
  raise ArticleValidationError, "read_time must look like '3 min read'" unless metadata["read_time"].to_s.match?(/\A\d+ min read\z/)

  validate_https_url(metadata["source_url"], "source_url")
  %w[date source_published last_reviewed].each { |field| parse_date(metadata[field], field) }
  validate_additional_sources(metadata)
  validate_local_image(metadata, path)
  validate_headings(body)

  if body.match?(/\b(?:TODO|TBD)\b/i)
    raise ArticleValidationError, "body contains an unresolved TODO or TBD"
  end
  sources_section = body.split(/^## Sources\s*$/, 2)[1].to_s
  unless sources_section.include?(metadata["source_url"].to_s)
    raise ArticleValidationError, "Sources section must include source_url"
  end

  words = body_word_count(body)
  unless words.between?(MIN_WORDS, MAX_WORDS)
    raise ArticleValidationError, "body must contain #{MIN_WORDS}–#{MAX_WORDS} words (found #{words})"
  end

  words
end

paths = ARGV.flat_map { |argument| Dir.glob(argument) }.uniq.sort.map { |entry| Pathname.new(entry) }
paths = Dir.glob(ROOT.join("_articles", "*.md")).sort.map { |entry| Pathname.new(entry) } if paths.empty?

if paths.empty?
  warn "No Article Bites found."
  exit 0
end

failed = false
paths.each do |path|
  begin
    words = validate_article(path)
    puts "PASS #{path}: #{words} words"
  rescue Errno::ENOENT
    warn "FAIL #{path}: file not found"
    failed = true
  rescue ArticleValidationError => e
    warn "FAIL #{path}: #{e.message}"
    failed = true
  end
end

exit(failed ? 1 : 0)
