require "spec_helper"
require "deadweight_rails/ruby_analyzer"

RSpec.describe DeadweightRails::RubyAnalyzer do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:app_dir) { File.join(tmp_dir, "app/models") }

  before do
    FileUtils.mkdir_p(app_dir)
  end

  after do
    FileUtils.remove_entry(tmp_dir)
  end

  it "detects unused methods" do
    file_path = File.join(app_dir, "user.rb")
    File.write(file_path, <<~RUBY)
      class User
        def used_method; end
        def unused_method; end
        used_method
      end
    RUBY

    analyzer = described_class.new(tmp_dir)
    result = analyzer.scan

    expect(result[:unused_methods]).to include(:unused_method)
    expect(result[:unused_methods]).not_to include(:used_method)
  end

  it "handles multiple files and methods" do
    file1 = File.join(app_dir, "a.rb")
    file2 = File.join(app_dir, "b.rb")
    File.write(file1, "def used_a; end; used_a")
    File.write(file2, "def unused_b; end")

    analyzer = described_class.new(tmp_dir)
    result = analyzer.scan

    expect(result[:unused_methods]).to include(:unused_b)
    expect(result[:unused_methods]).not_to include(:used_a)
  end
end
