module ActiveFedora::Aggregation
  class Reflection < ActiveFedora::Reflection::AssociationReflection
    def association_class
      ThroughAssociation
    end

    def collection?
      true
    end
  end
end
