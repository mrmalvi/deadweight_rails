require "find"

module DeadweightRails
  class RubyAnalyzer
    def initialize(path)
      @path = path
    end

    def scan
      files = Dir[File.join(@path, "app/**/*.rb")]
      classes = Hash.new { |h, k| h[k] = [] }       # class => [methods]
      usages  = Hash.new { |h, k| h[k] = [] }       # class => [used methods]

      files.each do |file|
        current_class = nil
        content = File.read(file)

        content.each_line do |line|
          # Detect class definitions
          if line =~ /^\s*class\s+([\w:]+)/
            current_class = $1
          end

          # Detect method definitions
          if line =~ /^\s*def\s+([\w\?\!]+)/
            classes[current_class] << $1 if current_class
          end

          # Detect method calls (simple: .method_name or method_name())
          next if current_class.nil?
          classes[current_class].each do |method|
            usages[current_class] << method if line.match?(/(\.| )#{Regexp.escape(method)}(\(|\s)/)
          end
        end
      end

      # Unused = defined - used
      result = {}
      classes.each do |klass, methods|
        used = usages[klass] || []
        unused = methods - used
        result[klass] = unused if unused.any?
      end

      result
    end
  end
end
