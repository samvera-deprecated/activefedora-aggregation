module ActiveFedora::Aggregation
  class IndirectContainer < ActiveFedora::Base
    type ::RDF::Vocab::LDP.IndirectContainer

    def self.contained_class
      "ActiveFedora::Base"
    end

    property :membership_resource, predicate: ::RDF::Vocab::LDP.membershipResource
    property :member_relation, predicate: ::RDF::Vocab::LDP.hasMemberRelation
    property :inserted_content_relation, predicate: ::RDF::Vocab::LDP.insertedContentRelation
    property :contained, :predicate => ::RDF::Vocab::LDP.contains, :class_name => contained_class

    validates :membership_resource, :member_relation, :inserted_content_relation, :presence => true

    def contained=(*args)
      raise NoMethodError
    end

  end
end
