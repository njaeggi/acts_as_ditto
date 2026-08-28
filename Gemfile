# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "irb"
gem "rake", "~> 13.0"

gem "rspec", "~> 3.0"

gem "rubocop", "~> 1.21"

gem "activerecord", ">= 6.1"
gem "sqlite3", "~> 2.0"

group :postgresql, optional: true do
  gem "pg", "~> 1.5"
end

group :mysql, optional: true do
  gem "mysql2", "~> 0.5"
end
