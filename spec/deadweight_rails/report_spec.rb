require "spec_helper"
require "deadweight_rails/report"

RSpec.describe DeadweightRails::Report do
  it "prints asset and ruby results" do
    asset_results = { unused_css: ["old.css"], unused_js: ["legacy.js"] }
    ruby_results  = { unused_methods: [:old_helper] }

    report = described_class.new(asset_results, ruby_results)

    expect { report.print }.to output { |output|
      expect(strip_colors(output)).to include("Unused JS:  legacy.js")
    }.to_stdout
  end
end
