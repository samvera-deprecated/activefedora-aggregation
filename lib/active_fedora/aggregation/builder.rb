module ActiveFedora::Aggregation
  module Builder
    extend ActiveSupport::Concern

    included do
      after_save :save_aggregator
    end

    def save_aggregator
      generic_files.save
    end

    # has_one :aggregation
    # has_many :generic_files, through: :aggregation
    def generic_files
      @file_association ||= FileAssociation.new(self, { class_name: 'GenericFile' } )
    end

    def generic_files=(vals)
      generic_files.target = vals
    end

    def generic_file_ids=(vals)
      generic_files.target_ids = vals
    end

    def generic_file_ids
      generic_files.target_ids
    end
  end
end
