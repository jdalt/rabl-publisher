module Rabl
  class Engine
    def dataview_parent(klass, options={})
      # TODO: incorporate versioning here?
      options.merge!({class: klass.to_s, published_at: Time.now})
      fake_block = ->(obj) { options }
      @_options[:node].push({ :name => 'metadata', :options => {}, :block => fake_block })
    end
  end

  module Helpers
  end
end


