module Publisher
  class PushResource
    extend Publisher::Util
    @queue = :high

    def self.perform(resource_id, resource_class, requested_at)
      # TODO: check last published time against requested_at
      resource = resource_class.constantize.find(resource_id)
      payload = Rabl.render(resource, resource_filename(resource), :view_path => 'app/publish', :format => :json)
      res = Typhoeus.post("localhost:3000/publish", body: payload, headers: {'Content-Type' => 'application/json'})
      # use exponential stand off if failed?
      puts res.request.response.body
    end

    # rabl file for resource
    def self.resource_filename(resource)
      klasses_snake = super_klasses_snake(resource.class)
      klasses_snake.each do |snake_klass|
        path = Rails.root + "app/publish/#{snake_klass}.rabl"
        return snake_klass if File.exists?(path)
      end
      ""
    end

    def self.super_klasses_snake(klass)
      super_klasses(klass).map { |klazz| klazz.to_s.underscore }
    end
  end
end
