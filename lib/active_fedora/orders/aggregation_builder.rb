module ActiveFedora::Orders
  class AggregationBuilder < ActiveFedora::Associations::Builder::Association
    self.valid_options = [:through, :class_name, :has_member_relation]

    def self.build(model, name, options)
      new(model, name, options).build
    end

    def build
      model.indirectly_contains name, has_member_relation: has_member_relation, through: proxy_class, foreign_key: proxy_foreign_key, inserted_content_relation: inserted_content_relation
      model.contains contains_key, class_name: list_source_class
      model.orders name, through: contains_key
    end

    private

    def has_member_relation
      options[:has_member_relation] || ::RDF::DC.hasPart
    end

    def inserted_content_relation
      ::RDF::Vocab::ORE::proxyFor
    end

    def proxy_class
      "ActiveFedora::Aggregation::Proxy"
    end

    def proxy_foreign_key
      :target
    end

    def contains_key
      options[:through]
    end

    def list_source_class
      "ActiveFedora::Aggregation::ListSource"
    end
  end
end

