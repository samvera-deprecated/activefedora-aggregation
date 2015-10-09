module ActiveFedora
  module Aggregation
    class ListSource < ActiveFedora::Base
      property :head, predicate: ::RDF::Vocab::IANA['first'], multiple: false
      property :tail, predicate: ::RDF::Vocab::IANA.last, multiple: false
      property :nodes, predicate: ::RDF::DC::hasPart

      def save(*args)
        return true if has_unpersisted_proxy_for? || !changed?
        persist_ordered_self if ordered_self.changed?
        super
      end

      def changed?
        super || ordered_self.changed?
      end

      # Ordered list representation of proxies in graph.
      def ordered_self
        @ordered_self ||= ordered_list_factory.new(resource, head_subject, tail_subject)
      end

      # Allow this to be set so that -=, += will work.
      # @param [ActiveFedora::Orders::OrderedList] An ordered list object this
      #   graph should contain.
      def ordered_self=(new_ordered_self)
        @ordered_self = new_ordered_self
      end

      # Serializing head/tail/nodes slows things down CONSIDERABLY, and is not
      # useful.
      # @note This method is used by ActiveFedora::Base upstream for indexing,
      #   at https://github.com/projecthydra/active_fedora/blob/master/lib/active_fedora/profile_indexing_service.rb.
      def serializable_hash(options=nil)
        options ||= {}
        options[:except] ||= []
        options[:except] += [:head, :tail, :nodes]
        super
      end

      private

      def persist_ordered_self
        nodes_will_change!
        # Delete old statements
        ordered_list_factory.new(resource, head_subject, tail_subject).to_graph.statements.each do |s|
          resource.delete s
        end
        # Assert head and tail
        self.head = ordered_self.head.next.rdf_subject
        self.tail = ordered_self.tail.prev.rdf_subject
        graph = ordered_self.to_graph
        resource << graph
        # Set node subjects to a term in AF JUST so that AF will persist the
        # sub-graphs.
        # TODO: Find a way to fix this.
        self.nodes = nil
        self.nodes += graph.subjects.to_a
        ordered_self.changes_committed!
      end

      def has_unpersisted_proxy_for?
        ordered_self.flat_map(&:target).compact.select(&:new_record?).find{|x| x.respond_to?(:uri)}
      end

      def head_subject
        head_id.first
      end

      def tail_subject
        tail_id.first
      end

      def ordered_list_factory
        ActiveFedora::Orders::OrderedList
      end
    end
  end
end
