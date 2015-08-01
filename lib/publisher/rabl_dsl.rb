module Publisher
  # TODO: how do I access an inner class from an external class?
  class RablDsl
    attr_accessor :publish_chain

    def self.process_file(template_name, nesting_level=0, publish_chain={})
      template_code = File.read(path(template_name))
      template_class = get_klass(template_name)
      rdsl = RablDsl.new(template_class, nesting_level, publish_chain)
      rdsl.instance_eval(template_code)
      rdsl.publish_chain
    end

    def self.get_klass(template_name)
      klass_name = String.new(template_name)
      klass_name.slice!("partials/")
      klass_name.camelize.constantize
    end

    def self.path(template_name)
      # TODO: add to gem config
      Rails.root + "app/publish/#{template_name}.rabl"
    end

    def initialize(root, nesting_level, publish_chain)
      @root = root
      @publish_chain = publish_chain
      @nesting_level = nesting_level
    end

    def child(data, options={}, &block)
      @nesting_level += 1
      parent = @publish_chain[@nesting_level - 1].last if @nesting_level > 1
      @publish_chain[@nesting_level] = [] if @publish_chain[@nesting_level].nil?
      @publish_chain[@nesting_level] << { method: data.keys.first, parent: parent }
      yield if block_given?
      @nesting_level -= 1
    end

    def extends(partial_name)
      RablDsl.process_file(partial_name, @nesting_level, @publish_chain)
    end

    def method_missing(name, *args, &block)
      puts name
    end

    # TODO: test with conditional lambdas
  end
end
