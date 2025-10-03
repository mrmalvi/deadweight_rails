require "spec_helper"
require "deadweight_rails/report"

RSpec.describe DeadweightRails::Report do
  let(:asset_results) do
    {
      unused_css: ["app/assets/stylesheets/unused.css", "app/assets/stylesheets/imported.css"],
      unused_js: ["app/assets/javascripts/unused.js"]
    }
  end

  let(:ruby_results) do
    {
      unused_methods: {
        "Customer" => ["first_name", "last_name"],
        "LoanCase" => ["calculate_interest"]
      }
    }
  end

  let(:css_class_results) do
    {
      "app/assets/stylesheets/used.css" => ["unused_class", "another_unused_class"]
    }
  end

  it "prints a report with unused CSS, JS, Ruby methods, and CSS classes" do
    report = described_class.new(asset_results, ruby_results, css_class_results)

    output = capture_stdout { report.print }

    # Strip ANSI color codes
    clean_output = output.gsub(/\e\[[0-9;]*m/, "")

    expect(clean_output).to include("Unused CSS Files: unused.css, imported.css")
    expect(clean_output).to include("Unused JS Files:  unused.js")
    expect(clean_output).to include("Customer: first_name, last_name")
    expect(clean_output).to include("LoanCase: calculate_interest")
    expect(clean_output).to include("app/assets/stylesheets/used.css: unused_class, another_unused_class")
  end

  # helper to capture stdout
  def capture_stdout(&block)
    old_stdout = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end
