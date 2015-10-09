module ActiveFedora::Orders
  class Builder < ActiveFedora::Associations::Builder::CollectionAssociation
    include ActiveFedora::AutosaveAssociation::AssociationBuilderExtension
    self.macro = :orders
    self.valid_options += [:through, :ordered_reflection]

    def self.define_readers(mixin, name)
      super
      mixin.redefine_method("#{name.to_s.gsub("_proxies","").pluralize}") do
        association(name).target_reader
      end
    end

    def initialize(model, name, options)
      @original_name = name
      @model = model
      name = :"ordered_#{name.to_s.singularize}_proxies"
      options = {ordered_reflection: ordered_reflection}.merge(options)
      super
    end

    def build
      super.tap do
        model.property :head, predicate: ::RDF::Vocab::IANA['first'], multiple: false
        model.property :tail, predicate: ::RDF::Vocab::IANA.last, multiple: false
      end
    end

    private

    def ordered_reflection
      model.reflect_on_association(@original_name)
    end
  end
end

