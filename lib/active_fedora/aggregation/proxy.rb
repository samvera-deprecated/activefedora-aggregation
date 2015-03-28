module ActiveFedora::Aggregation
  class Proxy < ActiveFedora::Base
    # HABTM is actually only belongs to one
    has_and_belongs_to_many :containers, predicate: ::RDF::Vocab::ORE.proxyIn, class_name: 'ActiveFedora::Base'
    belongs_to :target, predicate: ::RDF::Vocab::ORE.proxyFor, class_name: 'ActiveFedora::Base'
    belongs_to :next, predicate: ::RDF::Vocab::IANA.next, class_name: 'ActiveFedora::Aggregation::Proxy'
    belongs_to :prev, predicate: ::RDF::Vocab::IANA.prev, class_name: 'ActiveFedora::Aggregation::Proxy'

    type ::RDF::Vocab::ORE.Proxy

    def as_list
      if self.next
        [self] + self.next.as_list
      else
        [self]
      end
    end
  end
end
