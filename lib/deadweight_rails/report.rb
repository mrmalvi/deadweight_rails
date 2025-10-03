require "colorize"

module DeadweightRails
  class Report
    def initialize(asset_results, ruby_results, css_class_results = {})
      @assets           = asset_results
      @ruby             = ruby_results
      @css_class_results = css_class_results
    end

    def print
      puts "\n🔎 DeadweightRails Report".upcase.colorize(:cyan)

      # Assets
      puts "\n--- Assets ---".colorize(:green)
      puts "Unused CSS Files: #{@assets[:unused_css].map { |f| File.basename(f) }.join(", ")}"
      puts "Unused JS Files:  #{@assets[:unused_js].map { |f| File.basename(f) }.join(", ")}"

      # CSS Classes
      unless @css_class_results.empty?
        puts "\n--- Unused CSS Classes ---".colorize(:green)
        @css_class_results.each do |file, classes|
          puts "#{file}: #{classes.join(", ")}"
        end
      end

      # Ruby
      puts "\n--- Ruby ---".colorize(:green)
      if @ruby[:unused_methods].empty?
        puts "No unused methods detected."
      else
        @ruby[:unused_methods].each do |klass, methods|
          puts "#{klass}: #{methods.join(", ")}"
        end
      end
    end
  end
end
