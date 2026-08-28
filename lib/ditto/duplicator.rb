# frozen_string_literal: true

module Ditto
  # Builds a duplicate of a record based on `Ditto::Configuration`.
  class Duplicator
    def initialize(record, configuration)
      @record = record
      @configuration = configuration
    end

    def duplicate
      new_record = @record.dup

      reset_attributes_to_default(new_record)
      nullify_attributes(new_record)
      apply_static_values(new_record)
      apply_prefixes(new_record)
      apply_suffixes(new_record)
      apply_transformations(new_record)
      clone_associations(new_record)

      new_record
    end

    private

    def reset_attributes_to_default(new_record)
      @configuration.defaulted_attributes.each do
        new_record[_1] = new_record.class.column_defaults[_1.to_s]
      end
    end

    def nullify_attributes(new_record)
      @configuration.nullified_attributes.each { new_record[_1] = nil }
    end

    def apply_static_values(new_record)
      @configuration.static_values.each { |attribute, value| new_record[attribute] = value }
    end

    def apply_prefixes(new_record)
      @configuration.prefixes.each do |attribute, value|
        new_record[attribute] = "#{value}#{new_record[attribute]}"
      end
    end

    def apply_suffixes(new_record)
      @configuration.suffixes.each do |attribute, value|
        new_record[attribute] = "#{new_record[attribute]}#{value}"
      end
    end

    def apply_transformations(new_record)
      @configuration.transformations.each do |attribute, block|
        new_record[attribute] = block.call(@record, @record[attribute])
      end
    end

    def clone_associations(new_record)
      @configuration.cloned_associations.each do |name|
        reflection = @record.class.reflect_on_association(name)
        next unless reflection

        if reflection.collection?
          clone_collection_association(new_record, name)
        else
          clone_singular_association(new_record, name)
        end
      end
    end

    def clone_collection_association(new_record, name)
      @record.public_send(name).each do |associated_record|
        new_record.public_send(name) << duplicate_of(associated_record)
      end
    end

    def clone_singular_association(new_record, name)
      associated_record = @record.public_send(name)
      return unless associated_record

      new_record.public_send(:"#{name}=", duplicate_of(associated_record))
    end

    # Duplicates an associated record with its own ditto configuration
    # if it has one, otherwise uses an empty ditto configuration which
    # mirros a plain dup
    def duplicate_of(record)
      configuration =
        if record.class.respond_to?(:ditto_configuration)
          record.class.ditto_configuration
        else
          Configuration.new
        end

      self.class.new(record, configuration).duplicate
    end
  end
end
