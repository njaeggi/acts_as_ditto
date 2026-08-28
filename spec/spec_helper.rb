# frozen_string_literal: true

require "acts_as_ditto"
require "active_record"

CONNECTION_CONFIG = {
  "sqlite3" => { adapter: "sqlite3", database: ":memory:" },
  "postgresql" => {
    adapter: "postgresql",
    database: ENV.fetch("DITTO_TEST_DATABASE", "ditto_test"),
    host: ENV.fetch("DITTO_TEST_HOST", "localhost"),
    username: ENV.fetch("DITTO_TEST_USERNAME", "postgres"),
    password: ENV.fetch("DITTO_TEST_PASSWORD", "postgres")
  },
  "mysql" => {
    adapter: "mysql2",
    database: ENV.fetch("DITTO_TEST_DATABASE", "ditto_test"),
    host: ENV.fetch("DITTO_TEST_HOST", "127.0.0.1"),
    username: ENV.fetch("DITTO_TEST_USERNAME", "root"),
    password: ENV.fetch("DITTO_TEST_PASSWORD", "")
  }
}.freeze

adapter = ENV.fetch("DB", "sqlite3")

ActiveRecord::Base.establish_connection(CONNECTION_CONFIG.fetch(adapter))

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.string :status, default: "invited"
    t.string :api_token
    t.datetime :confirmed_at
  end

  create_table :posts, force: true do |t|
    t.integer :user_id
    t.integer :category_id
    t.string :title
    t.text :body
  end

  create_table :categories, force: true do |t|
    t.string :name
  end

  create_table :addresses, force: true do |t|
    t.integer :user_id
    t.string :street
    t.string :house_number
    t.string :zip_code
    t.string :city
    t.string :country
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :body
  end
end

class User < ActiveRecord::Base
  has_many :posts
  has_one :address
end

class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :category, optional: true
  has_many :comments
end

class Category < ActiveRecord::Base
  has_many :posts
end

class Address < ActiveRecord::Base
  belongs_to :user
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

module DittoHelpers
  # Applies configuration to active record class for the examples in
  # the current group only, restoring its previous configuration afterwards.
  def configure_ditto(klass, &block)
    around do |example|
      original_configuration = klass.ditto_configuration if klass.respond_to?(:ditto_configuration)
      klass.acts_as_ditto(&block)
      example.run
      klass.ditto_configuration = original_configuration || Ditto::Configuration.new
    end
  end
end

RSpec.configure do |config|
  config.extend DittoHelpers

  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    ActiveRecord::Base.transaction(requires_new: true) do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
