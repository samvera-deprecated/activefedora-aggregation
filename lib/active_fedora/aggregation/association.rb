module ActiveFedora::Aggregation
  class Association

    # @param [ActiveFedora::Base] parent
    # @param [Reflection] reflection
    # @opts options [String] class_name name of the class in the association
    def initialize(parent, reflection)
      @parent = parent
      @reflection = reflection
    end

    def klass
      @reflection.klass
    end

    def == other
      container.to_a == other
    end

    def create(&block)
      klass.create(&block).tap do |created|
        container << created
      end
      save #causes the (head/tail) pointers on the aggregation to be persisted
    end

    def save
      container.save
    end

    def target=(vals)
      container.target=(vals)
    end

    def target_ids=(vals)
      container.target_ids=(vals)
    end

    def target_ids
      container.target_ids
    end

    def container
      @container ||= begin
         ProxyContainer.find_or_initialize(klass.uri_to_id(uri)).tap do |container|
           container.parent = @parent
         end
      end
    end

    def first
      container.first
    end

    def uri
      @parent.uri + '/files'
    end
  end
end
