# frozen_string_literal: true

module DeadweightRails
  class CSSClassAnalyzer
    # Returns a hash of { "filename.css" => [unused_class1, unused_class2] }
    def initialize(path)
      @path = path
    end

    def scan
      css_files = Dir[File.join(@path, "app/assets/stylesheets/**/*.{css,scss,sass}")]
      views     = Dir[File.join(@path, "app/views/**/*.{erb,haml,slim}")].map { |f| File.read(f) }

      unused_classes = {}

      css_files.each do |file|
        content = File.read(file)
        classes = content.scan(/\.(\w[\w-]*)/).flatten

        unused = classes.reject do |cls|
          views.any? { |view| view.include?(cls) }
        end

        unused_classes[File.basename(file)] = unused unless unused.empty?
      end

      unused_classes
    end
  end
end
