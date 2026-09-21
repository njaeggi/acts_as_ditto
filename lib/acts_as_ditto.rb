# frozen_string_literal: true

require "active_support"

require_relative "ditto/version"
require_relative "ditto/configuration"
require_relative "ditto/duplication/duplication_context"
require_relative "ditto/duplication/duplicator"
require_relative "ditto/acts_as_ditto"

ActiveSupport.on_load(:active_record) do
  include Ditto::ActsAsDitto
end
