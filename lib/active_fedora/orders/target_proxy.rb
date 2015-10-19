module ActiveFedora
  module Orders
    class TargetProxy
      attr_reader :association
      delegate :+, to: :to_a
      def initialize(association)
        @association = association
      end

      def <<(obj)
        association.append_target(obj)
        self
      end

      def concat(objs)
        objs.each do |obj|
          self.<<(obj)
        end
        self
      end

      def clear
        while to_ary.present?
          association.delete_at(0)
        end
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
