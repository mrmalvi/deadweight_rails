require "spec_helper"
require "deadweight_rails/asset_analyzer"

RSpec.describe DeadweightRails::AssetAnalyzer do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:views_dir) { File.join(tmp_dir, "app/views") }
  let(:css_dir)   { File.join(tmp_dir, "app/assets/stylesheets") }
  let(:js_dir)    { File.join(tmp_dir, "app/assets/javascripts") }

  before do
    FileUtils.mkdir_p([views_dir, css_dir, js_dir])
  end

  after do
    FileUtils.remove_entry(tmp_dir)
  end

  it "detects unused CSS files" do
    used_css = File.join(css_dir, "used.css")
    unused_css = File.join(css_dir, "unused.css")

    File.write(used_css, ".btn {}")
    File.write(unused_css, ".old-class {}")

    File.write(File.join(views_dir, "index.html.erb"), "<div class='btn'></div>")

    analyzer = described_class.new(tmp_dir)
    result = analyzer.scan

    expect(result[:unused_css]).to include(unused_css)
    expect(result[:unused_css]).not_to include(used_css)
  end

  it "detects unused JS files" do
    used_js = File.join(js_dir, "used.js")
    unused_js = File.join(js_dir, "legacy.js")

    File.write(used_js, "console.log('hello')")
    File.write(unused_js, "console.log('old')")

    File.write(File.join(views_dir, "show.html.erb"), "<script src='used.js'></script>")

    analyzer = described_class.new(tmp_dir)
    result = analyzer.scan

    expect(result[:unused_js]).to include(unused_js)
    expect(result[:unused_js]).not_to include(used_js)
  end
end
