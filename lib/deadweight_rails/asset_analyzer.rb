module DeadweightRails
  class AssetAnalyzer
    def initialize(path)
      @path = path
    end

    def scan
      views = Dir[File.join(@path, "app/views/**/*.{erb,haml,slim}")].map { |f| File.read(f) }

      css_files = Dir[File.join(@path, "app/assets/stylesheets/**/*.css*")]
      js_files  = Dir[File.join(@path, "app/assets/javascripts/**/*.js*")]

      unused_css = css_files.select do |file|
        content = File.read(file)
        selectors = content.scan(/\.(\w[\w-]*)/)
        selectors.flatten.all? { |s| views.none? { |v| v.include?(s) } }
      end

      unused_js = js_files.select do |file|
        name = File.basename(file, ".js")
        views.none? { |v| v.include?(name) }
      end

      { unused_css: unused_css, unused_js: unused_js }
    end
  end
end
