module ActiveFedora::Aggregation
  class ProxyContainer < ActiveFedora::Base
    type ::RDF::Vocab::LDP.IndirectContainer

    property :membership_resource, predicate: ::RDF::Vocab::LDP.membershipResource
    property :member_relation, predicate: ::RDF::Vocab::LDP.hasMemberRelation
    property :inserted_content_relation, predicate: ::RDF::Vocab::LDP.insertedContentRelation

    after_initialize :default_relations

    def parent
      @parent || raise("Parent hasn't been set on #{self.class}")
    end

    def parent=(parent)
      @parent = parent
      self.membership_resource = [::RDF::URI(parent.uri)]
    end

    def default_relations
      self.member_relation = [::RDF::URI.new("http://pcdm.org/hasMember")] # TODO wrong predicate!
      self.inserted_content_relation = [::RDF::Vocab::ORE.proxyFor]
    end

    def first
      parent.head.target
    end

    # This can be a very expensive operation. avoid if possible
    def to_a
      @target ||= list_of_proxies.map(&:target)
    end

    def target= (collection)
      link_target(build_proxies(collection))
    end

    def target_ids=(object_ids)
      link_target(build_proxies_with_ids(object_ids))
    end

    # Set the links on the nodes in the list
    def link_target(new_proxies)
      new_proxies.each_with_index do |proxy, idx|
        proxy.next_id = new_proxies[idx+1].id unless new_proxies.length - 1 <= idx
        proxy.prev_id = new_proxies[idx-1].id unless idx == 0
      end

      parent.head = new_proxies.first
      parent.tail = new_proxies.last
      parent.proxies = new_proxies
    end

    # TODO clear out the old proxies (or reuse them)
    def build_proxies(objects)
      # need to create the proxies before we can add the links otherwise the linked to resource won't exist
      objects.map do |object|
        Proxy.create(id: mint_proxy_id, target: object)
      end
    end

    # TODO clear out the old proxies (or reuse them)
    def build_proxies_with_ids(object_ids)
      # need to create the proxies before we can add the links otherwise the linked to resource won't exist
      object_ids.map do |file_id|
        Proxy.create(id: mint_proxy_id, target_id: file_id)
      end
    end

    def target_ids
      list_of_proxies.map(&:target_id)
    end

    # @param obj [ActiveFedora::Base]
    def << (obj)
      node = if persisted?
               parent.proxies.create(id: mint_proxy_id, target: obj, prev: parent.tail)
             else
               parent.proxies.build(id: mint_proxy_id, target: obj, prev: parent.tail)
             end
      # set the old tail, if present, to have this new proxy as its next
      parent.tail.update(next: node) if parent.tail
      # update the tail to point at the new node
      parent.tail = node
      # if this is the first node, set it to be the head
      parent.head = node unless parent.head
      reset_target!
    end

    def mint_proxy_id
      "#{id}/#{SecureRandom.uuid}"
    end

    def self.find_or_initialize(id)
      find(id)
    rescue ActiveFedora::ObjectNotFoundError
      new(id)
    end

    def reset_target!
      @proxy_list = nil
      @target = nil
    end

    # return the proxies in order
    def list_of_proxies
      @proxy_list ||= if parent.head
        parent.head.as_list
      else
        []
      end
    end
  end
end
