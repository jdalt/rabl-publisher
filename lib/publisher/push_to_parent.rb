module Publisher
  class PushToParent
    extend Publisher::Util

    @queue = :low

    def self.perform(resource_id, resource_class, requested_at)
      resource = resource_class.constantize.find(resource_id)
      call_chains(resource.class).each do |chain|
        obj = nil
        obj = resource if chain.length > 0
        chain.each do |method|
          obj = obj.send(method)
        end
        Resque.enqueue(Publisher::PushResource, obj.id, obj.class.to_s, requested_at) if obj
      end

    end

    # looks for call chain of class and all relevant super classes
    def self.call_chains(klass)
      super_klasses(klass).each do |klass|
        chains = Publisher.child_lookup_hash[klass.to_s]
        return chains if chains
      end
      []
    end

  end
end
