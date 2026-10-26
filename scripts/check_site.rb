#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks a built site (output of scripts/build.sh):
#   - repository-only documents (AGENTS.md, POLICY_*, plans) were not published
#   - every page has a <title>, and Bite pages do not reuse the bare site title
#   - root-relative links and assets resolve to built files
#
#   ruby scripts/check_site.rb /path/to/_site

Encoding.default_external = Encoding::UTF_8

require "cgi"
require "pathname"
require "uri"

site = Pathname.new(ARGV.fetch(0) { abort "Usage: check_site.rb <built-site-dir>" })
abort "Built site not found: #{site}" unless site.directory?

LEAK_PATTERN = /\A(?:AGENTS|POLICY_[A-Z_]+|PLAN_[A-Z_]+|README|USAGE)(?:\.md|\.html|\/)/
errors = []

Pathname.glob(site.join("**", "*")).each do |path|
  relative = path.relative_path_from(site).to_s
  next unless path.file?

  if relative.split("/").any? { |part| part.match?(LEAK_PATTERN) || part.match?(/\A(?:AGENTS|POLICY_[A-Z_]+|PLAN_[A-Z_]+|USAGE)\.(?:md|html)\z/) }
    errors << "repository document was published: /#{relative} (add it to _config.yml exclude)"
  end
end

def resolve(site, url)
  path = CGI.unescape(URI.parse(url).path.to_s)
  return true if path.empty?

  target = site.join(path.delete_prefix("/"))
  target.file? || target.join("index.html").file? || Pathname.new("#{target}.html").file?
rescue URI::InvalidURIError
  false
end

titles = Hash.new { |hash, key| hash[key] = [] }
Pathname.glob(site.join("**", "*.html")).sort.each do |page|
  relative = "/#{page.relative_path_from(site)}"
  html = page.read
  next if html.match?(/<meta http-equiv="refresh"/i)

  title = html[%r{<title>(.*?)</title>}m, 1].to_s.strip
  if title.empty?
    errors << "#{relative}: missing <title>"
  else
    titles[title] << relative
  end

  html.scan(/\s(?:href|src)="([^"]+)"/).flatten.uniq.each do |url|
    next unless url.start_with?("/") && !url.start_with?("//")

    errors << "#{relative}: broken internal link #{url}" unless resolve(site, url)
  end
end

titles.each do |title, pages|
  bites = pages.select { |page| page.match?(%r{\A/(?:articles|posts|data)/[^/]+/index\.html\z}) }
  errors << "#{bites.length} Bite pages share the title '#{title}'" if bites.length > 1
end

if errors.empty?
  puts "Site check passed: #{titles.values.flatten.length} pages."
else
  errors.uniq.each { |error| warn "FAIL #{error}" }
  exit 1
end
