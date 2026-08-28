# frozen_string_literal: true

require "active_support"

require_relative "ditto/version"
require_relative "ditto/configuration"
require_relative "ditto/duplicator"
require_relative "ditto/acts_as_ditto"

module Ditto
  class Error < StandardError; end
end

ActiveSupport.on_load(:active_record) do
  include Ditto::ActsAsDitto
end
