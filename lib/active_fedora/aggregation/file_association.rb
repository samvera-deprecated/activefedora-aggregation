module ActiveFedora::Aggregation
  # TODO this is a has_one (child) association
  class FileAssociation

    # @param [ActiveFedora::Base] parent
    # @param [Reflection] reflection
    # @opts options [String] class_name name of the class in the association
    def initialize(parent, reflection)
      @parent = parent
      @reflection = reflection
    end

    # TODO this moves to reflection
    def klass
      @reflection.klass
    end

    def == other
      aggregation.to_a == other
    end

    def create(&block)
      klass.create(&block).tap do |created|
        aggregation << created
      end
      save #causes the (head/tail) pointers on the aggregation to be persisted
    end

    def save
      aggregation.save
    end

    def target=(vals)
      aggregation.target=(vals)
    end

    def target_ids=(vals)
      aggregation.target_ids=(vals)
    end

    def target_ids
      aggregation.target_ids
    end

    def aggregation
      @aggregation ||= Aggregator.find_or_initialize(klass.uri_to_id(uri))
    end

    def first
      aggregation.first
    end

    def uri
      @parent.uri + '/files'
    end
  end
end
