module Publisher
  mattr_accessor :child_publish, :root_publish, :root_objects

  class Engine < ::Rails::Engine
    isolate_namespace Publisher

    config.after_initialize do |app|
      Publisher.root_publish = PublishInitializer.root_publish
      Publisher.child_publish = PublishInitializer.child_publish
      Publisher::Callbacks.bind(Publisher.root_publish, Publisher.child_publish)
    end

  end
end
