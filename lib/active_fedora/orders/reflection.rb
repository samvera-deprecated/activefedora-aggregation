module ActiveFedora::Orders
  class Reflection < ActiveFedora::Reflection::AssociationReflection
    def association_class
      Association
    end

    def collection?
      true
    end

    def class_name
      klass.to_s
    end

    def ordered_reflection
      options[:ordered_reflection]
    end

    def klass
      ActiveFedora::Orders::ListNode
    end
  end
end

