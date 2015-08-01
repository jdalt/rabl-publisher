module Publisher
  mattr_accessor :child_lookup_hash, :root_objects

  class Engine < ::Rails::Engine
    isolate_namespace Publisher

    # defaults; may want to provide mechanism to override via yaml in host app
    config.before_initialize do |app|
      Publisher.root_objects = PublishInitializer.glob_files.map(&:camelize)
    end

    config.after_initialize do |app|
      Publisher.child_lookup_hash = PublishInitializer.get_lookup_chain
    end

  end
end
