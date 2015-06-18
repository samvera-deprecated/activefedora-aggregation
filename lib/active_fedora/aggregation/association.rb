module ActiveFedora::Aggregation
  class Association < ::ActiveFedora::Associations::IndirectlyContainsAssociation
    delegate :first, to: :ordered_reader

    def ordered_reader
      OrderedReader.new(owner).to_a
    end

    def proxy_class
      @proxy_class ||= ProxyRepository.new(owner, super)
    end

    def options
      @all_options ||= default_options.merge(super)
    end

    private

    def default_options
      { through: default_proxy_class, foreign_key: :target, has_member_relation: reflection.predicate, inserted_content_relation: content_relation }
    end

    def content_relation
      default_proxy_class.constantize.reflect_on_association(:target).predicate
    end

    def default_proxy_class
      'ActiveFedora::Aggregation::Proxy'
    end

  end
end
