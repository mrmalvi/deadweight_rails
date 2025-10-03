require "fileutils"

module DeadweightRails
  class AssetAnalyzer
    MANIFEST_CSS = ["application.css", "application.scss", "application.sass"].freeze
    MANIFEST_JS  = ["application.js"].freeze

    def initialize(path)
      @path = path
    end

    def scan
      views = Dir[File.join(@path, "app/views/**/*.{erb,haml,slim}")].map { |f| File.read(f) }

      css_files = Dir[File.join(@path, "app/assets/stylesheets/**/*.{css,scss,sass}")]
      js_files  = Dir[File.join(@path, "app/assets/javascripts/**/*.js")]

      used_css = track_used_css(css_files, views)
      used_js  = track_used_js(js_files, views)

      unused_css = css_files.reject do |f|
        MANIFEST_CSS.include?(File.basename(f)) ||
          used_css.include?(File.basename(f, ".*"))
      end

      unused_js = js_files.reject do |f|
        MANIFEST_JS.include?(File.basename(f)) ||
          used_js.include?(File.basename(f, ".js"))
      end

      { unused_css: unused_css, unused_js: unused_js }
    end

    private

    # Recursively track used CSS via @import and views
    def track_used_css(files, views)
      used = []
      processed = []

      traverse = lambda do |file|
        return if file.nil? || processed.include?(file)
        processed << file

        content  = File.read(file)
        basename = File.basename(file, ".*")

        # Mark as used if selectors match a view
        used << basename if views.any? { |v| content_match_views?(content, v) }

        # Follow imports
        imports = content.scan(/@import\s+["']([\w\/-]+)["']/).flatten
        imports.each do |import_name|
          import_file = files.find { |f| File.basename(f, ".*") == import_name }
          next unless import_file

          used << File.basename(import_file, ".*")
          traverse.call(import_file)

          used << basename
        end
      end

      # Always start from manifest files if they exist
      manifest_files = files.select { |f| MANIFEST_CSS.include?(File.basename(f)) }
      if manifest_files.any?
        manifest_files.each { |f| traverse.call(f) }
      else
        files.each { |f| traverse.call(f) }
      end

      used.uniq
    end


    # Recursively track used JS via //= require and views
    def track_used_js(files, views)
      used = []
      processed = []

      traverse = lambda do |file|
        return if file.nil? || processed.include?(file)
        processed << file

        content  = File.read(file)
        basename = File.basename(file, ".js")
        used << basename

        # Follow requires
        requires = content.scan(/\/\/=\s*require\s+([\w\/-]+)/).flatten
        requires.each do |req_name|
          req_file = files.find { |f| File.basename(f, ".js") == req_name }
          traverse.call(req_file)
        end
      end

      # Always start from manifest files
      manifest_files = files.select { |f| MANIFEST_JS.include?(File.basename(f)) }
      manifest_files.each { |f| traverse.call(f) }

      # Also check files referenced in views
      files.each do |f|
        traverse.call(f) if views.any? { |v| v.include?(File.basename(f, ".js")) }
      end

      used.uniq
    end

    def content_match_views?(content, view)
      selectors = content.scan(/\.(\w[\w-]*)/).flatten
      selectors.any? { |s| view.include?(s) }
    end
  end
end
