module ActiveFedora::Aggregation
  class Association < ::ActiveFedora::Associations::IndirectlyContainsAssociation

    def ordered_reader
      OrderedReader.new(owner).to_a
    end

    def add_link(proxy)
      LinkInserter.new(owner, proxy).call
    end

    def save_through_record(record)
      super.tap do |proxy|
        add_link(proxy)
      end
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
