# frozen_string_literal: true

module Ditto
  # Tracks records that have already been duplicated during a single
  # `ditto` call
  class DuplicationContext
    def initialize
      @duplicates = {}
    end

    def duplicate_of(record)
      @duplicates[identity_for(record)]
    end

    def register(record, duplicate)
      @duplicates[identity_for(record)] = duplicate
    end

    private

    def identity_for(record)
      record.persisted? ? [record.class.name, record.id] : record.object_id
    end
  end
end
