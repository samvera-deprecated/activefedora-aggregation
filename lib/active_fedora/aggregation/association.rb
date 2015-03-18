module ActiveFedora::Aggregation
  class Association
    def initialize(owner, reflection)
      @owner, @reflection = owner, reflection
    end

    # has_one :aggregation
    # has_many :generic_files, through: :aggregation
    def reader
      @file_association ||= FileAssociation.new(@owner, @reflection)
    end

    def writer(vals)
      reader.target = vals
    end

    def ids_writer(vals)
      reader.target_ids = vals
    end

    def ids_reader
      reader.target_ids
    end
  end
end
