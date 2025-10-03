require "spec_helper"
require "fileutils"
require "deadweight_rails/asset_analyzer"

RSpec.describe DeadweightRails::AssetAnalyzer do
  let(:tmp_dir) { File.join(Dir.pwd, "tmp_test") }

  before(:each) do
    FileUtils.mkdir_p(tmp_dir)

    # Create views
    views_dir = File.join(tmp_dir, "app/views/home")
    FileUtils.mkdir_p(views_dir)
    File.write(File.join(views_dir, "index.html.erb"), "<div class='used'></div>")

    # Create CSS
    css_dir = File.join(tmp_dir, "app/assets/stylesheets")
    FileUtils.mkdir_p(css_dir)
    File.write(File.join(css_dir, "used.css"), ".used {}")
    File.write(File.join(css_dir, "imported.css"), "@import 'used';")
    File.write(File.join(css_dir, "unused.css"), ".unused {}")

    # Create JS
    js_dir = File.join(tmp_dir, "app/assets/javascripts")
    FileUtils.mkdir_p(js_dir)
    File.write(File.join(js_dir, "application.js"), "//= require legacy")
    File.write(File.join(js_dir, "legacy.js"), "console.log('legacy')")
    File.write(File.join(js_dir, "unused.js"), "console.log('unused')")
  end

  after(:each) do
    FileUtils.remove_entry(tmp_dir)
  end

  it "detects unused CSS files" do
    result = described_class.new(tmp_dir).scan
    unused = result[:unused_css].map { |f| File.basename(f) }

    expect(unused).to include("unused.css")
    expect(unused).not_to include("used.css")
    expect(unused).not_to include("imported.css")
  end

  it "detects unused JS files" do
    result = described_class.new(tmp_dir).scan
    unused = result[:unused_js].map { |f| File.basename(f) }

    expect(unused).to include("unused.js")
    expect(unused).not_to include("application.js")
    expect(unused).not_to include("legacy.js")
  end
end
