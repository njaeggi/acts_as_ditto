# frozen_string_literal: true

module Ditto
  # Holds the ditto configuration for the model
  class Configuration
    attr_reader :cloned_associations, :nullified_attributes, :static_values,
                :prefixes, :suffixes, :transformations, :defaulted_attributes

    def initialize
      @cloned_associations = []
      @nullified_attributes = []
      @static_values = {}
      @prefixes = {}
      @suffixes = {}
      @transformations = {}
      @defaulted_attributes = []
    end

    def clone_associations(*names)
      @cloned_associations.concat(names.map(&:to_sym))
    end

    def nullify(*attributes)
      @nullified_attributes.concat(attributes.map(&:to_sym))
    end

    def override(attributes = {})
      @static_values.merge!(attributes.transform_keys(&:to_sym))
    end

    def prefix(attribute, value)
      @prefixes[attribute.to_sym] = value
    end

    def suffix(attribute, value)
      @suffixes[attribute.to_sym] = value
    end

    def reset_to_default(*attributes)
      @defaulted_attributes.concat(attributes.map(&:to_sym))
    end

    def transform(attribute, &block)
      raise ArgumentError, "transform requires a block" unless block

      @transformations[attribute.to_sym] = block
    end
  end
end
