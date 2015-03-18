module ActiveFedora::Aggregation
  class Reflection < ActiveFedora::Reflection::AssociationReflection
    def association_class
      Association
    end
  end
end
