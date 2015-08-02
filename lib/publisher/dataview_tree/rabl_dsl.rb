module Publisher
  class RablDsl
    include Rabl::Helpers

    def self.process_file(template_name, dataview=nil)
      template_code = File.read(path(template_name))
      rdsl = RablDsl.new(template_name, dataview)
      rdsl.instance_eval(template_code)
      rdsl.original_dataview_node
    end

    def self.path(template_name)
      # TODO: add to gem config
      Rails.root + "app/publish/#{template_name}.rabl"
    end

    attr_accessor :template_name, :original_dataview_node, :current_dataview_node

    def initialize(template_name, dataview_node)
      @template_name = template_name
      @original_dataview_node = @current_dataview_node = dataview_node
    end

    def child(data, options={}, &block)
      return unless current_dataview_node # consider raising an exception
      dsl_method = data_name(data).to_sym
      new_dataview_node = DataviewNode.new(parent: @current_dataview_node, source_method: dsl_method, source_template: template_name)
      @current_dataview_node.children << new_dataview_node
      @current_dataview_node = new_dataview_node
      yield if block_given?
    end

    def dataview_parent(klass, collection, version, options={})
      root_dataview_node = DataviewRootNode.new(klass: klass.to_s, source_template: template_name)
      @original_dataview_node = @current_dataview_node = root_dataview_node
    end

    def extends(partial_name)
      return unless current_dataview_node # consider raising an exception
      current_dataview_node.extension_templates << partial_name
      RablDsl.process_file(partial_name, current_dataview_node)
    end

    def method_missing(name, *args, &block)
      puts name
    end

    def get_child_method(data)

    end

    # TODO: test with conditional lambdas
  end
end
