# frozen_string_literal: true

require "active_support/concern"

module Ditto
  # Add the ditto instance methods
  module InstanceMethods
    def ditto
      Ditto::Duplicator.new(self, self.class.ditto_configuration).duplicate
    end

    def ditto!
      ditto.tap(&:save!)
    end
  end

  # Adds `acts_as_ditto` to ActiveRecord models.
  module ActsAsDitto
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_ditto(&block)
        configuration = Ditto::Configuration.new
        configuration.instance_eval(&block) if block

        class_attribute :ditto_configuration, instance_writer: false, default: configuration
        include Ditto::InstanceMethods
      end
    end
  end
end
