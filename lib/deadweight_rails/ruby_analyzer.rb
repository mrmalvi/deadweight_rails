require "parser/current"

module DeadweightRails
  class RubyAnalyzer
    def initialize(path)
      @path = path
      @defined_methods = []
      @called_methods  = []
    end

    def scan
      ruby_files = Dir[File.join(@path, "app/**/*.rb")]

      ruby_files.each do |file|
        ast = Parser::CurrentRuby.parse(File.read(file))
        walk(ast) if ast
      end

      unused_methods = @defined_methods - @called_methods
      { unused_methods: unused_methods }
    end

    private

    def walk(node)
      return unless node.is_a?(Parser::AST::Node)

      @defined_methods << node.children.first if node.type == :def
      @called_methods  << node.children[1] if node.type == :send

      node.children.each { |child| walk(child) if child.is_a?(Parser::AST::Node) }
    end
  end
end
