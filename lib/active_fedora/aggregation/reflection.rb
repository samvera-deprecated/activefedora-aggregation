module ActiveFedora::Aggregation
  class Reflection < ActiveFedora::Reflection::AssociationReflection
    def association_class
      ThroughAssociation
    end

    def klass
      @klass ||= begin
        klass = if Object.const_defined? class_name
          class_name.constantize
        else
          ActiveFedora::Base
        end

        klass.respond_to?(:uri_to_id) ? klass : ActiveFedora::Base
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
