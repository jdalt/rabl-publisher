module Publisher
  module Callbacks
    extend Publisher::Util

    # TODO: bind deletes
    def self.bind(root_list, child_list)
      root_list.each do |klass_name, _|
        klass = klass_name.constantize
        push_resource = proc { Resque.enqueue(Publisher::PushResource, self.id, klass_name, Time.now) }

        # Need to manually traverse inheritance tree b/c callbacks bound after
        # class definition aren't inherited :(
        self_and_descandants(klass).each do |callback_klass|
          callback_klass.after_save ->{ instance_eval(&push_resource) }
        end
      end

      child_list.each do |klass_name, _|
        klass = klass_name.constantize
        # publish_to_parent = proc { Resque.enqueue(Publisher::PushToParent, self.id, klass_name, Time.now) }
        # klass.after_save ->{ instance_eval(&publish_to_parent) }
      end
    end

  end
end
