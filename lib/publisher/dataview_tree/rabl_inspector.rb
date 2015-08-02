module Publisher
  class RablInspector

    def self.process_template(template_name)
      root_view = RablDsl.process_file(template_name)
      classify_tree(root_view)
      calculate_callchain(root_view)
      root_view
    end

    def self.classify_tree(dataview)
      dataview.children.each do |child_dataview|
        classify_and_reverse(child_dataview)
        classify_tree(child_dataview)
      end
    end

    def self.calculate_callchain(dataview)
      dataview.children.each { |dv| calculate_callchain(dv) } # DFS

      return unless dataview.parent

      callchain = []
      current_view = dataview
      while(current_view) do
        callchain << current_view.reverse_method unless current_view.is_root?
        current_view = current_view.parent
      end

      dataview.root_callchain = callchain
    end

    def self.classify_and_reverse(dataview)
      klass = dataview.parent.klass.constantize
      method = dataview.source_method
      ar_meta = klass.reflections[method] if klass.respond_to?(:reflections)
      mongoid_meta = klass.associations[method.to_s] if klass.respond_to?(:associations)
      am_meta = klass.am_relations[method.to_s] if klass.respond_to?(:am_relations)

      if ar_meta
        self.ar_obj(ar_meta, klass, method, dataview)
      elsif mongoid_meta
        self.mongoid_obj(mongoid_meta, klass, method, dataview)
      elsif am_meta
        self.mongoid_obj(am_meta, klass, method, dataview)
      end
    end

    def self.ar_obj(meta, klass, method, dataview)
      target_klass = reverse_method = nil
      options = meta.options
      if options
        target_klass = options[:class_name] if options[:class_name]
        reverse_method = options[:inverse_of].to_sym if options[:inverse_of]
      end
      target_klass = method.to_s.singularize.camelize unless target_klass
      reverse_method = klass.to_s.underscore.to_sym unless reverse_method
      dataview.klass = target_klass
      dataview.reverse_method = reverse_method
    end

    def self.mongoid_obj(meta, klass, method, dataview)
      dataview.klass =  method.to_s.singularize.camelize
      dataview.reverse_method = (meta[:as] || klass.to_s.underscore).to_sym
    end

  end
end
