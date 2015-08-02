module Publisher
  class PushToParent
    @queue = :low

    def self.perform(resource_id, resource_class, requested_at)
      resource = resource_class.constantize.find(resource_id)
      dataviews = Publisher.child_publish[resource_class]
      dataviews.each do |dataview|
        root_resource = dataview.find_parent(resource)
        raise RuntimeException unless root_resource
        root_resource_id = root_resource.id
        root_class = dataview.root_class
        Resque.enqueue(Publisher::PushResource, root_resource_id, root_class, requested_at) if root_resource_id # TODO: consider exception here
      end
    end
  end
end
