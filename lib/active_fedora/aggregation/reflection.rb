module ActiveFedora::Aggregation
  class Reflection < ActiveFedora::Reflection::AssociationReflection
    def association_class
      Association
    end

    def collection?
      true
    end
  end
end
