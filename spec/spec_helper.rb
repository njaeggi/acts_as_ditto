# frozen_string_literal: true

require "ditto"
require "active_record"
require "securerandom"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

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
    t.string :title
    t.text :body
  end

  create_table :addresses, force: true do |t|
    t.integer :user_id
    t.string :street
    t.string :house_number
    t.string :zip_code
    t.string :city
    t.string :country
  end
end

class User < ActiveRecord::Base
  has_many :posts
  has_one :address
end

class Post < ActiveRecord::Base
  belongs_to :user
end

class Address < ActiveRecord::Base
  belongs_to :user
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
