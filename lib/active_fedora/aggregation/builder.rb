module ActiveFedora::Aggregation
  class Builder < ActiveFedora::Associations::Builder::CollectionAssociation
    self.macro = :aggregation

    def build
      reflection = super
      configure_dependency
      model.has_and_belongs_to_many :proxies, predicate: ::RDF::Vocab::ORE.aggregates, class_name: 'ActiveFedora::Aggregation::Proxy', inverse_of: :containers
      model.belongs_to :head, predicate: ::RDF::Vocab::IANA['first'], class_name: 'ActiveFedora::Aggregation::Proxy'
      model.belongs_to :tail, predicate: ::RDF::Vocab::IANA.last, class_name: 'ActiveFedora::Aggregation::Proxy'

      reflection
    end

    def self.define_readers(mixin, name)
      super
      mixin.redefine_method("#{name.to_s.singularize}_ids") do
        association(name).ids_reader
      end
    end

    def self.define_writers(mixin, name)
      super
      mixin.redefine_method("#{name.to_s.singularize}_ids=") do |ids|
        association(name).ids_writer(ids)
      end
    end

    private

      def configure_dependency
        define_save_dependency_method
        model.after_save dependency_method_name
      end

      def define_save_dependency_method
        name = self.name
        model.send(:define_method, dependency_method_name) do
          send(name).save
        end
      end

      def dependency_method_name
        "aggregator_dependent_for_#{name}"
      end

  end
end
