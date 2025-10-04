require "fileutils"

RSpec.describe DeadweightRails::RubyAnalyzer do
  let(:tmp_dir) { File.join(Dir.pwd, "tmp_test_app") }

  before(:each) do
    # Create a temporary app folder
    FileUtils.mkdir_p(File.join(tmp_dir, "app", "models"))

    # Create dummy Ruby files under app/models
    File.write(File.join(tmp_dir, "app", "models", "customer.rb"), <<~RUBY)
      class Customer
        def used_method; end
        def unused_method; end
      end
    RUBY

    File.write(File.join(tmp_dir, "app", "models", "loan_case.rb"), <<~RUBY)
      class LoanCase
        def active; end
        def inactive; end
      end
    RUBY
  end

  after(:each) do
    FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)
  end

  it "detects unused methods grouped by class" do
    analyzer = DeadweightRails::RubyAnalyzer.new(tmp_dir)
    result = analyzer.scan

    expect(result.keys).to include("Customer", "LoanCase")
    expect(result["Customer"]).to include(:used_method, :unused_method)
    expect(result["LoanCase"]).to include(:active, :inactive)
  end
end
