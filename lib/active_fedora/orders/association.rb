module ActiveFedora::Orders
  class Association < ::ActiveFedora::Associations::CollectionAssociation

    def initialize(*args)
      super
      @target = find_target
    end

    def reader(*args)
      @proxy ||= ActiveFedora::Orders::CollectionProxy.new(self)
      super
    end

    def target_reader
      @target_proxy ||= TargetProxy.new(self)
    end

    class TargetProxy
      attr_reader :association
      def initialize(association)
        @association = association
      end

      def <<(obj)
        association.append_target(obj)
      end

      def to_ary
        association.reader.map(&:target).dup
      end
      alias_method :to_a, :to_ary

      def ==(other_obj)
        case other_obj
        when TargetProxy
          super
        when Array
          to_a == other_obj
        end
      end
    end

    def find_reflection
      reflection
    end

    def replace(new_ordered_list)
      raise unless new_ordered_list.kind_of? ActiveFedora::Orders::OrderedList
      list_container.ordered_self = new_ordered_list
      @target = find_target
    end


    def find_target
      ordered_proxies
    end

    def load_target
      @target = find_target
    end

    # Append a target node to the end of the order.
    # @param [ActiveFedora::Base] record Record to append
    def append_target(record, skip_callbacks=false, &block)
      unless unordered_association.target.include?(record)
        unordered_association.concat(record)
      end
      target.append_target(record, proxy_in: owner)
    end

    # Insert a target node in a specific position
    # @param [Integer] loc Position to insert record.
    # @param [ActiveFedora::Base] record Record to insert
    def insert_target_at(loc, record)
      unless unordered_association.target.include?(record)
        unordered_association.concat(record)
      end
      target.insert_at(loc, record)
    end

    # Delete whatever node is at a specific position
    # @param [Integer] loc Position to delete
    def delete_at(loc)
      target.delete_at(loc)
    end

    # Delete multiple list nodes.
    # @param [Array<ActiveFedora::Orders::ListNode>] records
    def delete_records(records, _method)
      records.each do |record|
        delete_record(record)
      end
    end

    # Delete a list node
    # @param [ActiveFedora::Orders::ListNode] record Node to delete.
    def delete_record(record)
      list_container.delete_node(record)
    end

    def insert_record(record, force=true, validate=true)
      record.save_target
      list_container.save
      # NOTE: This turns out to be pretty cheap, but should we be doing it
      # elsewhere?
      unless list_container.changed?
        owner.head = list_container.head_id.first
        owner.tail = list_container.tail_id.first
        owner.save
      end
    end

    def scope(*args)
      @scope ||= ActiveFedora::Relation.new(klass)
    end

    private

    def ordered_proxies
      list_container.ordered_self
    end

    def create_list_node(record)
      node = ListNode.new(RDF::URI.new("#{list_container.uri}##{::RDF::Node.new.id}"), list_container.resource)
      node.proxyIn = owner
      node.proxyFor = record
      node
    end

    def association_scope
      nil
    end

    def list_container
      list_container_association.reader
    end
    
    def list_container_association
      owner.association(options[:through])
    end

    def unordered_association
      owner.association(ordered_reflection_name)
    end

    def ordered_reflection_name
      reflection.ordered_reflection.name
    end
  end
end
