#!/usr/bin/env ruby
# frozen_string_literal: true

# Compatibility entry point: validates Article Bites only.
# New work should call `scripts/litebites validate` (scripts/validate_bites.rb).

require_relative "validate_bites"

ARGV.replace(Dir.glob(ROOT.join("_articles", "*.md").to_s).sort) if ARGV.empty?
exit(run_validator(ARGV, forced_type: "article"))
