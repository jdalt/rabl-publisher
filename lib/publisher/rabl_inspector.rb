module Publisher
  class RablInspector

    def self.process_template(template_name)
      chain = RablDsl.process_file(template_name)
      template_klass = RablDsl.get_klass(template_name)
      chain[1].each { |desc| desc[:klass] = template_klass }
      process_chain(chain, template_klass)
    end

    def self.process_chain(chain, root_class)
      desc = chain[1].first
      chain.each do |level, descriptors|
        descriptors.each do |desc|
          klass = desc[:klass]
          method = desc[:method]
          desc.merge!(target_and_reverse(klass, method))
        end
        next_level = chain[level + 1]
        if next_level
          next_level.each do |desc|
            desc[:klass] = desc[:parent][:target_klass]
          end
        end
      end
    end

    def self.target_and_reverse(klass, method)
      ar_meta = klass.reflections[method] if klass.respond_to?(:reflections)
      mongoid_meta = klass.associations[method.to_s] if klass.respond_to?(:associations)
      am_meta = klass.am_relations[method.to_s] if klass.respond_to?(:am_relations)

      if ar_meta
        self.ar_obj(ar_meta, klass, method)
      elsif mongoid_meta
        self.mongoid_obj(mongoid_meta, klass, method)
      elsif am_meta
        self.mongoid_obj(am_meta, klass, method)
      end
    end

    def self.ar_obj(meta, klass, method)
      target_klass = reverse_method = nil
      options = meta.options
      if options
        target_klass = options[:class_name].constantize if options[:class_name]
        reverse_method = options[:inverse_of].to_sym if options[:inverse_of]
      end
      target_klass = method.to_s.singularize.camelize.constantize unless target_klass
      reverse_method = klass.to_s.underscore.to_sym unless reverse_method
      {target_klass: target_klass, reverse_method: reverse_method}
    end

    def self.mongoid_obj(meta, klass, method)
      target_klass = (meta[:class_name] || method.to_s.singularize.camelize).constantize
      reverse_method = (meta[:as] || klass.to_s.underscore).to_sym
      {target_klass: target_klass, reverse_method: reverse_method}
    end

  end
end
