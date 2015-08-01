module Publisher
  class PublishInitializer

    class << self

      def glob_files
        Dir.glob('app/publish/*.rabl').map {|f| f[/app\/publish\/(.*)\.rabl/,1] }
      end

      def get_lookup_chain
        root_publish_hash = {}
        glob_files.each do |file_name|
          klass = RablDsl.get_klass(file_name)
          root_publish_hash[klass] = RablInspector.process_template(file_name)
        end
        convert_to_call_chain(root_publish_hash)
      end

      def convert_to_call_chain(root_hash)
        call_chain_hash = {}
        root_hash.each do |root_obj,v|
          v.each do |level, descs|
            descs.each do |desc|
              call_array = []
              get_child_chain(desc, call_array)
              merge_chain = unfold_chain(call_array, root_obj)
              call_chain_hash.merge!(merge_chain)
            end
          end
        end
        flatten_call_chain(call_chain_hash)
      end

      def flatten_call_chain(call_chain)
        flat_chain = {}
        call_chain.each do |mapping_hash, method_array|
          flat_chain[mapping_hash.keys.first] ||= []
          flat_chain[mapping_hash.keys.first] << method_array
        end
        flat_chain
      end

      def get_child_chain(obj_hash, call_array)
        call_array << { obj_hash[:reverse_method] => obj_hash[:target_klass] }
        if(obj_hash[:parent])
          get_child_chain(obj_hash[:parent], call_array)
        end
      end

      def unfold_chain(call_array, root_obj)
        merge_hash = {}
        call_array.each do |method_obj|
          method = method_obj.keys.first
          publish_obj = method_obj.values.first
          # circular references not allowed in rabl
          merge_hash.each do |obj_root_hash, method_array|
            method_array << method
          end
          merge_hash[{ publish_obj.to_s => root_obj.to_s }] = [method]
        end
        merge_hash
      end

    end
  end
end
