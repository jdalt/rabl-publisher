module Publisher
  class DataviewNode
    attr_accessor :klass, :parent, :children, :source_template, :source_method,
      :extension_templates, :reverse_method, :root_callchain

    def initialize(options)
      @children = []
      @extension_templates = []
      options.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def find_parent(resource)
      obj = resource
      root_callchain.each do |method|
        obj = obj.send(method)
      end
      obj
    end

    def root_class
      current_view = self
      while(!current_view.is_root?) do
        current_view = current_view.parent
      end
      current_view.klass
    end

    def is_root?
      false
    end
  end
end
