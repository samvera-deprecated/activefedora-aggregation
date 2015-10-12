module ActiveFedora
  module Orders
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
  end
end
