# frozen_string_literal: true

require "colorize"

module DeadweightRails
  class Report
    def initialize(asset_results, ruby_results, css_classes = {})
      @assets = asset_results || {}
      @ruby   = ruby_results || {}
      @css_classes = css_classes || {} # optional: per-file unused CSS classes
    end

    def print
      puts "\n🔎 DEADWEIGHTRAILS REPORT".upcase.colorize(:cyan)

      print_assets
      print_css_classes
      print_ruby_methods
    end

    private

    def print_assets
      puts "\n--- Assets ---".colorize(:green)

      unused_css = (@assets[:unused_css] || []).map { |f| File.basename(f) }
      unused_js  = (@assets[:unused_js] || []).map { |f| File.basename(f) }

      puts "Unused CSS Files: #{unused_css.join(", ")}"
      puts "Unused JS Files:  #{unused_js.join(", ")}"
    end

    def print_css_classes
      return if @css_classes.empty?

      puts "\n--- Unused CSS Classes ---".colorize(:green)
      @css_classes.each do |file, classes|
        next if classes.nil? || classes.empty?

        puts "#{file}: #{classes.join(", ")}"
      end
    end

    def print_ruby_methods
      unused_methods = @ruby[:unused_methods] || {}

      return if unused_methods.empty?

      puts "\n--- Ruby ---".colorize(:green)
      unused_methods.each do |klass, methods|
        next if methods.nil? || methods.empty?

        puts "#{klass}: #{methods.join(", ")}"
      end
    end
  end
end
