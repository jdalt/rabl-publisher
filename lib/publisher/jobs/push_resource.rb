module Publisher
  class PushResource
    extend Publisher::Util
    @queue = :high

    def self.perform(resource_id, resource_class, requested_at)
      # CONSIDER: we can check requested_at XOR use sliding window or other job
      # strategy to prevent multiple requests to publish the same job by
      # multiple children.
      resource = resource_class.constantize.find(resource_id)
      dataviews = Publisher.root_publish[resource_class]
      # CONSIDER: exception of log warning if no dataviews found for class?
      # Lean exception.
      dataviews.each do |dataview|
        payload = Rabl.render(resource, dataview.source_template, :view_path => 'app/publish', :format => :json)
        res = Typhoeus.post("localhost:3000/publish", body: payload, headers: {'Content-Type' => 'application/json'})
        # use exponential stand off if failed?
        puts res.request.response.body
      end
      nil
    end
  end
end
