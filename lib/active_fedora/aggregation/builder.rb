module ActiveFedora::Aggregation
  class Builder < ActiveFedora::Associations::Builder::CollectionAssociation
    include ActiveFedora::AutosaveAssociation::AssociationBuilderExtension
    self.macro = :aggregation
    self.valid_options += [
      :type_validator
    ]

    def build
      reflection = super
      model.belongs_to :head, predicate: ::RDF::Vocab::IANA['first'], class_name: 'ActiveFedora::Aggregation::Proxy'
      model.belongs_to :tail, predicate: ::RDF::Vocab::IANA.last, class_name: 'ActiveFedora::Aggregation::Proxy'

      model.send(:setup_persist_links_callback, reflection)
      reflection
    end

    def self.define_readers(mixin, name)
      super
      mixin.redefine_method("#{name.to_s.singularize}_ids") do
        association(name).ids_reader
      end
      mixin.redefine_method("ordered_#{name.to_s.pluralize}") do
        association(name).ordered_reader
      end
    end

    def self.define_writers(mixin, name)
      super
      mixin.redefine_method("#{name.to_s.singularize}_ids=") do |ids|
        association(name).ids_writer(ids)
      end
    end

  end
end
