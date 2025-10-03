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

        content.each_line.with_index do |line, idx|
          # Detect class definitions
          if line =~ /^\s*class\s+([\w:]+)/
            current_class = $1
          end

          # Detect method definitions
          if line =~ /^\s*def\s+([\w\?\!]+)/
            classes[current_class] << { name: $1, line: idx + 1 } if current_class
          end

          next if current_class.nil?

          # Detect method usage (simplified)
          classes[current_class].each do |m|
            method_name = m[:name]
            # Match `.method` or `method(` or `self.method` but ignore definition line
            if idx + 1 != m[:line] && line.match?(/(\.|self\.)#{Regexp.escape(method_name)}(\(|\s)/)
              usages[current_class] << method_name
            end
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
