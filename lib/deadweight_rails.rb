# frozen_string_literal: true

require "deadweight_rails/version"
require "deadweight_rails/asset_analyzer"
require "deadweight_rails/ruby_analyzer"
require "deadweight_rails/report"

module DeadweightRails
  def self.run(path: Dir.pwd)
    asset_results = AssetAnalyzer.new(path).scan
    ruby_results  = RubyAnalyzer.new(path).scan

    Report.new(asset_results, ruby_results).print
  end
end
