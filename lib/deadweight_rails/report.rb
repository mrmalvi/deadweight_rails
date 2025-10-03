require "colorize"

module DeadweightRails
  class Report
    def initialize(asset_results, ruby_results)
      @assets = asset_results
      @ruby   = ruby_results
    end

    def print
      puts "\n🔎 DeadweightRails Report".upcase.colorize(:cyan)
      puts "\n--- Assets ---".colorize(:green)
      puts "Unused CSS: #{@assets[:unused_css].join(", ")}"
      puts "Unused JS:  #{@assets[:unused_js].join(", ")}"

      puts "\n--- Ruby ---".colorize(:green)
      puts "Unused Methods: #{@ruby[:unused_methods].join(", ")}"
    end
  end
end
