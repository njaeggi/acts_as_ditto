# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

namespace :spec do
  desc "Run the spec suite against every supported database adapter"
  task :all do
    adapters = { "sqlite3" => nil, "postgresql" => "postgresql", "mysql" => "mysql" }

    adapters.each do |db, bundle_with|
      puts "\n Running specs against #{db}"
      env = { "DB" => db }
      env["BUNDLE_WITH"] = bundle_with if bundle_with

      system(env, "bundle install --quiet") || abort("bundle install failed for #{db}")
      system(env, "bundle exec rspec") || abort("Specs failed against #{db}")
    end
  end
end

task default: %i[spec rubocop]
