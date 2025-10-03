require "find"

module DeadweightRails
  class RubyAnalyzer
    def initialize(path)
      @path = path
    end

    def scan
      files = Dir[File.join(@path, "app/**/*.rb")]
      classes = Hash.new { |h, k| h[k] = [] }
      usages = Hash.new { |h, k| h[k] = [] }

      files.each do |file|
        content = File.read(file)

        current_class = nil
        content.each_line do |line|
          # Detect class definitions
          if line =~ /^\s*class\s+([\w:]+)/
            current_class = $1
          end

          # Detect method definitions
          if line =~ /^\s*def\s+([\w\?\!]+)/
            classes[current_class] << $1 if current_class
          end

          # Detect method calls (very naive: match .method_name)
          classes.values.flatten.each do |method|
            usages[current_class] << method if line.include?(method)
          end
        end
      end

      # Unused = defined - used
      result = {}
      classes.each do |klass, methods|
        unused = methods - usages.values.flatten
        result[klass] = unused if unused.any?
      end

      result
    end
  end
end
