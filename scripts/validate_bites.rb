#!/usr/bin/env ruby
# frozen_string_literal: true

# Schema-driven validator for Article, Paper, and Data Bites.
#
#   ruby scripts/validate_bites.rb                 # every Bite in the repo
#   ruby scripts/validate_bites.rb _posts/x.md     # specific files
#   ruby scripts/validate_bites.rb --type article path.md
#
# The contract lives in _data/bite_schema.yml and _data/tags.yml. Exit status
# is nonzero when any file fails.

Encoding.default_external = Encoding::UTF_8

require "pathname"

ROOT = Pathname.new(File.expand_path("..", __dir__)) unless defined?(ROOT)
ENV["BUNDLE_GEMFILE"] ||= ROOT.join("Gemfile").to_s

require "bundler/setup"
require_relative "lib/bite_checks"

SCHEMA = YAML.safe_load(ROOT.join("_data", "bite_schema.yml").read, aliases: false)
TAGS_PATH = ROOT.join(SCHEMA.fetch("tag_vocabulary"))
TAG_VOCABULARY = TAGS_PATH.file? ? Array(YAML.safe_load(TAGS_PATH.read)["tags"]).map(&:to_s) : nil
SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

def type_for(path, forced)
  return forced if forced

  folder = path.expand_path.dirname.basename.to_s
  SCHEMA.fetch("types").each { |name, rules| return name if rules["dir"] == folder }
  raise BiteValidationError, "cannot infer Bite type from folder '#{folder}'; pass --type article|paper|data"
end

def validate_filename(path, rules, metadata)
  name = path.basename(".md").to_s
  case rules["filename"]
  when "dated-slug"
    match = name.match(/\A(\d{4}-\d{2}-\d{2})-(.+)\z/)
    raise BiteValidationError, "filename must be YYYY-MM-DD-<slug>.md" unless match
    raise BiteValidationError, "slug '#{match[2]}' must be lowercase kebab-case" unless match[2].match?(SLUG_PATTERN)

    date = metadata["date"].is_a?(Date) ? metadata["date"].iso8601 : metadata["date"].to_s
    unless date == match[1]
      raise BiteValidationError, "filename date #{match[1]} must match front-matter date #{date}"
    end
  else
    raise BiteValidationError, "filename slug '#{name}' must be lowercase kebab-case" unless name.match?(SLUG_PATTERN)
  end
end

def validate_fields(metadata, rules)
  missing = rules.fetch("required").reject { |field| present?(metadata[field]) }
  raise BiteValidationError, "missing required fields: #{missing.join(', ')}" unless missing.empty?

  known = rules.fetch("required") + rules.fetch("optional", [])
  unknown = metadata.keys - known
  unless unknown.empty?
    raise BiteValidationError, "unknown front-matter fields: #{unknown.join(', ')} (allowed fields are listed in _data/bite_schema.yml)"
  end

  placeholders = metadata.select { |_field, value| value.to_s.match?(/\bTODO\b/) }.keys
  raise BiteValidationError, "replace TODO placeholders in: #{placeholders.join(', ')}" unless placeholders.empty?

  invalid_strings = rules.fetch("strings", []).select { |field| metadata.key?(field) && !non_blank_string?(metadata[field]) }
  unless invalid_strings.empty?
    raise BiteValidationError, "fields must be non-empty strings: #{invalid_strings.join(', ')}"
  end

  %w[layout type].each do |field|
    next unless rules[field]
    raise BiteValidationError, "#{field} must be '#{rules[field]}'" unless metadata[field] == rules[field]
  end

  tags = metadata["tags"]
  unless tags.is_a?(Array) && !tags.empty? && tags.all? { |tag| non_blank_string?(tag) }
    raise BiteValidationError, "tags must be a non-empty list of strings"
  end
  if TAG_VOCABULARY
    unknown_tags = tags - TAG_VOCABULARY
    unless unknown_tags.empty?
      raise BiteValidationError, "tags not in #{SCHEMA['tag_vocabulary']}: #{unknown_tags.join(', ')} (reuse an existing tag, or add it there deliberately)"
    end
  end

  if metadata.key?("long_form") && ![true, false].include?(metadata["long_form"])
    raise BiteValidationError, "long_form must be true or false (unquoted)"
  end

  if metadata.key?("read_time") && !metadata["read_time"].to_s.match?(Regexp.new(SCHEMA.fetch("read_time_pattern")))
    raise BiteValidationError, "read_time must look like '3 min read'"
  end

  rules.fetch("urls", []).each do |field|
    validate_https_url(metadata[field], field) if present?(metadata[field])
  end
  rules.fetch("dates", []).each do |field|
    parse_date(metadata[field], field) if present?(metadata[field])
  end
end

def validate_words(body, rules, metadata)
  range = rules["words"]
  return nil unless range

  words = body_word_count(body)
  if range["from"] && present?(metadata["date"])
    return words if parse_date(metadata["date"], "date") < Date.iso8601(range["from"])
  end
  max = metadata["long_form"] == true && range["long_form_max"] ? range["long_form_max"] : range.fetch("max")
  unless words.between?(range.fetch("min"), max)
    raise BiteValidationError, "body must contain #{range['min']}–#{max} words (found #{words})"
  end
  words
end

def validate_bite(path, forced_type = nil)
  metadata, body = split_front_matter(path.read(encoding: "UTF-8"))
  type = type_for(path, forced_type)
  rules = SCHEMA.fetch("types").fetch(type)

  validate_fields(metadata, rules)
  validate_filename(path, rules, metadata) if path.expand_path.to_s.start_with?(ROOT.to_s)
  validate_additional_sources(metadata)
  if (image = rules["image"])
    validate_local_image(metadata, path, field: image["field"], alt: image["alt"], dir: image["dir"])
  end

  raise BiteValidationError, "body contains an unresolved TODO or TBD" if body.match?(/\b(?:TODO|TBD)\b/i)

  source_links = []
  if (sections = rules["sections"])
    final = sections.fetch("final")
    validate_headings(body, final: final, min_narrative: sections.fetch("min_narrative"))
    final_section = body.split(/^## #{Regexp.escape(final)}\s*$/, 2)[1].to_s
    source_links = source_link_destinations(final_section)
    field = sections["source_field"]
    if field && !source_links.include?(metadata[field].to_s)
      raise BiteValidationError, "#{final} section must include #{field} as an exact link destination"
    end
  end

  checks = rules.fetch("checks", [])
  validate_remote_inline_images(body, source_links) if checks.include?("remote_images")
  validate_first_party_inline_figures(body, path, source_links) if checks.include?("first_party_figures")

  [type, validate_words(body, rules, metadata)]
end

def bite_paths(arguments)
  paths = arguments.flat_map { |argument| Dir.glob(argument) }.uniq.sort
  if paths.empty?
    paths = SCHEMA.fetch("types").values.flat_map { |rules| Dir.glob(ROOT.join(rules["dir"], "*.md").to_s) }.sort
  end
  paths.reject { |entry| File.basename(entry) == "AGENTS.md" }.map { |entry| Pathname.new(entry) }
end

def run_validator(argv, forced_type: nil)
  arguments = argv.dup
  if (index = arguments.index("--type"))
    forced_type = arguments[index + 1]
    unless SCHEMA.fetch("types").key?(forced_type)
      warn "--type must be one of: #{SCHEMA.fetch('types').keys.join(', ')}"
      return 2
    end
    arguments.slice!(index, 2)
  end

  paths = bite_paths(arguments)
  if paths.empty?
    warn "No Bites found."
    return 0
  end

  failed = false
  paths.each do |path|
    type, words = validate_bite(path, forced_type)
    puts "PASS #{path}: #{type}#{words ? ", #{words} words" : ''}"
  rescue Errno::ENOENT
    warn "FAIL #{path}: file not found"
    failed = true
  rescue BiteValidationError => e
    warn "FAIL #{path}: #{e.message}"
    failed = true
  end
  failed ? 1 : 0
end

exit(run_validator(ARGV)) if File.expand_path($PROGRAM_NAME) == File.expand_path(__FILE__)
