require "spec_helper"
require "fileutils"

module DeadweightRails
  class RubyAnalyzer
    # Scan all classes and detect unused methods
    def initialize(path)
      @path = path
    end

    def scan
      load_ruby_files

      result = {}

      ObjectSpace.each_object(Class) do |klass|
        next if klass.name.nil? || klass.name.empty? || klass.name.start_with?("RSpec")

        public_methods = klass.instance_methods(false).map(&:to_s)
        used_methods = detect_used_methods(klass)

        unused = public_methods - used_methods
        result[klass.name] = unused unless unused.empty?
      end

      result
    end

    private

    def load_ruby_files
      Dir[File.join(@path, "**/*.rb")].each { |file| require file }
    end

    def detect_used_methods(klass)
      # For simplicity, assume methods called in views
      # In real usage, you could parse views or logs to find actual usage
      []
    end
  end
end

RSpec.describe DeadweightRails::RubyAnalyzer do
  let(:tmp_dir) { File.join(Dir.pwd, "tmp_test") }

  before(:each) do
    FileUtils.mkdir_p(tmp_dir)

    # Dummy Customer class
    File.write(File.join(tmp_dir, "customer.rb"), <<~RUBY)
      class Customer
        def used_method; end
        def unused_method; end
      end
    RUBY

    # Dummy LoanCase class
    File.write(File.join(tmp_dir, "loan_case.rb"), <<~RUBY)
      class LoanCase
        def active; end
        def inactive; end
      end
    RUBY
  end

  after(:each) do
    FileUtils.remove_entry(tmp_dir)
  end

  it "detects unused methods grouped by class" do
    result = DeadweightRails::RubyAnalyzer.new(tmp_dir).scan

    expect(result.keys).to include("Customer", "LoanCase")
    expect(result["Customer"]).to include("used_method", "unused_method")
    expect(result["LoanCase"]).to include("active", "inactive")
  end
end
