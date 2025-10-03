# frozen_string_literal: true

require "deadweight_rails/version"
require "deadweight_rails/asset_analyzer"
require "deadweight_rails/ruby_analyzer"
require "deadweight_rails/css_class_analyzer" # NEW
require "deadweight_rails/report"

module DeadweightRails
  def self.run(path: Dir.pwd)
    asset_results     = AssetAnalyzer.new(path).scan
    ruby_results      = RubyAnalyzer.new(path).scan
    css_class_results = CSSClassAnalyzer.new(path).scan # NEW

    Report.new(asset_results, ruby_results, css_class_results).print
  end
end
