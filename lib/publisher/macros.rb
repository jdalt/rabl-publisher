module Publisher
  module Macros

    extend ActiveSupport::Concern

    module ClassMethods
      def publish_changes
        # todo: enqueue
        # todo: differentiate parent objs, child objs (diff jobs) and perhaps
        # todo: object deletion
        # CONSIDER: both root and child -- legal?
        # lookout for embedded objs

        publish_to_parent = proc { Resque.enqueue(Publisher::PushToParent, self.id, self.class.to_s, Time.now) }
        push_resource = proc { Resque.enqueue(Publisher::PushResource, self.id, self.class.to_s, Time.now) }

        if Publisher.root_objects.include?(self.to_s)
          after_save ->{ instance_eval(&push_resource) }
        else
          after_save ->{ instance_eval(&publish_to_parent) }
        end
      end
    end
  end
end
