require "parser/current"

module DeadweightRails
  class RubyAnalyzer
    def initialize(path)
      @path = path
      @defined_methods = Hash.new { |h, k| h[k] = [] }
      @called_methods  = Hash.new { |h, k| h[k] = [] }
    end

    def scan
      ruby_files = Dir[File.join(@path, "{app,lib}/**/*.rb")]

      ruby_files.each do |file|
        next unless File.file?(file)
        next if File.basename(file).to_s.include? "controller.rb"
        content = File.read(file)

        # 🧭 Debug: stop when analyzing company.rb
        begin
          ast = Parser::CurrentRuby.parse(content)
          walk(ast)
        rescue Parser::SyntaxError => e
          warn "⚠️ Skipping #{file}: #{e.message}"
        end
      end

      # Compute unused methods per class
      result = {}
      @defined_methods.each do |klass, methods|
        used = @called_methods[klass] || []
        unused = methods - used
        result[klass] = unused if unused.any?
      end

      puts "\n✅ Final detected methods:"
      pp @defined_methods

      result
    end

    private

    def walk(node, current_class = nil)
      return unless node.is_a?(Parser::AST::Node)

      case node.type
      when :class, :module
        const_node = node.children[0]
        class_name = extract_const_name(const_node)
        body = node.children[2]
        walk(body, class_name)

      when :def
        method_name = node.children[0]
        if current_class
          @defined_methods[current_class] << method_name
          puts "🟢 Found instance method #{method_name} in #{current_class}"
        else
          puts "⚪ Found method #{method_name} outside any class"
        end

      when :defs
        method_name = node.children[1]
        if current_class
          @defined_methods["#{current_class}.self"] << method_name
          puts "🔵 Found class method #{method_name} in #{current_class}"
        end
      end

      node.children.each do |child|
        walk(child, current_class) if child.is_a?(Parser::AST::Node)
      end
    end

    def extract_const_name(node)
      return nil unless node

      case node.type
      when :const
        parent_node, name_sym = node.children
        parent_name = extract_const_name(parent_node)
        name = name_sym.to_s
        parent_name ? "#{parent_name}::#{name}" : name
      when :cbase
        "" # Handles leading ::
      else
        nil
      end
    end
  end
end
