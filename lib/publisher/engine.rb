module Publisher
  mattr_accessor :child_publish, :root_publish, :root_objects

  class Engine < ::Rails::Engine
    isolate_namespace Publisher

    # defaults; may want to provide mechanism to override via yaml in host app
    config.before_initialize do |app|
      Publisher.root_objects = PublishInitializer.glob_files.map(&:camelize)
    end

    config.after_initialize do |app|
      Publisher.child_publish = PublishInitializer.child_publish
      Publisher.root_publish = PublishInitializer.root_publish
    end

  end
end
