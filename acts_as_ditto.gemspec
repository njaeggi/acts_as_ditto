# frozen_string_literal: true

require_relative "lib/ditto/version"

Gem::Specification.new do |spec|
  spec.name = "acts_as_ditto"
  spec.version = Ditto::VERSION
  spec.authors = ["Niklas Jäggi"]
  spec.email = ["jaeggi@puzzle.ch"]

  spec.summary = "Configurable ActiveRecord duplication."
  spec.description = "Ditto adds an acts_as_ditto DSL to ActiveRecord models for duplicating " \
                      "records with custom control over nullified attributes, static " \
                      "overrides, transformations, and recursively cloned associations."
  spec.homepage = "https://github.com/njaeggi/acts_as_ditto"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/master"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.1"
end
