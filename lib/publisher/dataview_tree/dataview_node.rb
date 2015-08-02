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

    def is_root?
      false
    end
  end
end
