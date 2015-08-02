module Publisher
  class PushResource
    @queue = :high

    def self.perform(resource_id, resource_class, requested_at)
      # CONSIDER: we can check requested_at XOR use sliding window or other job
      # strategy to prevent multiple requests to publish the same job by
      # multiple children.
      resource = resource_class.constantize.find(resource_id)
      dataviews = Publisher.root_publish[resource_class]
      # CONSIDER: exception XOR log warning if no dataviews found for class?
      # ...prefer exception....
      dataviews.each do |dataview|
        payload = Rabl.render(resource, dataview.source_template, :view_path => 'app/publish', :format => :json)
        res = Typhoeus.post("localhost:3000/publish", body: payload, headers: {'Content-Type' => 'application/json'})
        # use exponential stand off if failed?
        resp = res.request.response
        puts "*** Published #{resource_class} (id:#{resource_id}) #{resp.response_code} #{resp.body} #{resp.total_time} ***"
      end
      nil
    end
  end
end
