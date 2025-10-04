require "parser/current"

module DeadweightRails
  class RubyAnalyzer
    def initialize(path)
      @path = path
      @defined_methods = Hash.new { |h, k| h[k] = [] }
      @called_methods  = Hash.new { |h, k| h[k] = [] }
      @current_class   = nil
    end

    def scan
      ruby_files = Dir[File.join(@path, "app/**/*.rb")]

      ruby_files.each do |file|
        content = File.read(file)
        begin
          ast = Parser::CurrentRuby.parse(content)
          walk(ast) if ast
        rescue Parser::SyntaxError => e
          warn "Skipping #{file}: #{e.message}"
        end
      end

      result = {}
      @defined_methods.each do |klass, methods|
        used = @called_methods[klass] || []
        unused = methods - used
        result[klass] = unused if unused.any?
      end

      result
    end

    private

    def walk(node)
      return unless node.is_a?(Parser::AST::Node)

      case node.type
      when :class, :module
        prev_class = @current_class
        @current_class = full_class_name(node)
        walk_children(node)
        @current_class = prev_class
      when :def
        @defined_methods[@current_class] << node.children.first if @current_class
        walk_children(node)
      when :send
        method_name = node.children[1]
        @called_methods[@current_class] << method_name if @current_class && method_name
        walk_children(node)
      else
        walk_children(node)
      end
    end

    def walk_children(node)
      node.children.each { |child| walk(child) if child.is_a?(Parser::AST::Node) }
    end

    def full_class_name(node)
      if node.type == :class || node.type == :module
        const_node = node.children.first
        extract_const_name(const_node)
      end
    end

    def extract_const_name(node)
      return unless node
      case node.type
      when :const
        parent = extract_const_name(node.children[0])
        name   = node.children[1].to_s
        parent ? "#{parent}::#{name}" : name
      else
        nil
      end
    end
  end
end
