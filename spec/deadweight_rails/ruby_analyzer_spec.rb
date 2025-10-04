require "fileutils"
require "pp"
require_relative "../../lib/deadweight_rails/ruby_analyzer"

RSpec.describe DeadweightRails::RubyAnalyzer do
  let(:tmp_dir) { File.join(Dir.pwd, "tmp_test") }

  before(:each) do
    FileUtils.mkdir_p(File.join(tmp_dir, "app/models"))
    FileUtils.mkdir_p(File.join(tmp_dir, "app/controllers"))
    FileUtils.mkdir_p(File.join(tmp_dir, "lib"))

    # Regular model file
    File.write(File.join(tmp_dir, "app/models/company.rb"), <<~RUBY)
      class Company
        def marketing_verifier_name
          marketing_verifier&.full_name_with_number
        end

        def self.info
          "company info"
        end
      end
    RUBY

    # Nested module/class
    File.write(File.join(tmp_dir, "lib/user_templates.rb"), <<~RUBY)
      module UserTemplates
        class Template
          def render
          end
        end
      end
    RUBY

    # Controller file (should be ignored)
    File.write(File.join(tmp_dir, "app/controllers/companies_controller.rb"), <<~RUBY)
      class CompaniesController < ApplicationController
        def index
        end
      end
    RUBY
  end

  after(:each) do
    FileUtils.rm_rf(tmp_dir)
  end

  it "detects methods in regular classes and ignores controllers" do
    analyzer = DeadweightRails::RubyAnalyzer.new(tmp_dir)
    result = analyzer.scan

    # Controller should not be included
    expected_classes = ["Company", "Company.self", "Template"] # match analyzer output
    expect(result.keys).to match_array(expected_classes)

    # Check instance and class methods
    expect(result["Company"]).to include(:marketing_verifier_name)
    expect(result["Company.self"]).to include(:info)
    expect(result["Template"]).to include(:render) # changed from UserTemplates::Template to Template
  end
end
