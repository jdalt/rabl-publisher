module Publisher
  class PublishInitializer
    class << self

      def glob_files
        Dir.glob('app/publish/*.rabl').map {|f| f[/app\/publish\/(.*)\.rabl/,1] }
      end

      def root_publish
        @root_publish ||= begin
          root_dataviews_hash = {}
          root_dataviews.each do |root_view|
            root_dataviews_hash[root_view.klass] ||= []
            root_dataviews_hash[root_view.klass] << root_view
          end
          root_dataviews_hash
        end
      end

      def child_publish
        @child_publish ||= begin
          child_dataviews_hash = {}
          root_dataviews.each do |root_view|
            root_view.children.each { |child_view| mark_child(child_view, child_dataviews_hash) }
          end
          child_dataviews_hash
        end
      end

      def root_dataviews
        @root_dataviews ||= begin
          glob_files.map do |file_name|
            RablInspector.process_template(file_name)
          end
        end
      end
      private :root_dataviews

      def mark_child(child_view, hash)
        hash[child_view.klass] ||= []
        hash[child_view.klass] << child_view
        child_view.children.each { |cdv| mark_child(cdv, hash) }
      end
      private :mark_child

    end
  end
end
