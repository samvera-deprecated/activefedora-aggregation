module ActiveFedora::Aggregation
  class Reflection < ActiveFedora::Reflection::AssociationReflection
    def association_class
      ThroughAssociation
    end

    def klass
      klass = super
      # This check precludes an inferred class like ::File from being used.
      if klass.respond_to? :uri_to_id
        klass
      else
        ActiveFedora::Base
      end
    end

    def predicate
      @options[:predicate] || ::RDF::Vocab::ORE.aggregates
    end

    def collection?
      true
    end
  end
end
