# frozen_string_literal: true

require_relative "lib/deadweight_rails/version"

Gem::Specification.new do |spec|
  spec.name          = "deadweight_rails"
  spec.version       = DeadweightRails::VERSION
  spec.authors = ["mrmalvi"]
  spec.email = ["malviyak00@gmail.com"]

  spec.summary       = "Detect unused CSS/JS assets and Ruby methods/classes in Rails apps"
  spec.description   = "DeadweightRails scans your Rails project for dead assets and unused Ruby code."
  spec.homepage      = "https://github.com/mrmalvi/deadweight_rails"
  spec.license       = "MIT"


  spec.add_dependency "parser"
  spec.add_dependency "set"
  spec.add_dependency "colorize"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency 'rspec-rails', '~> 6.0'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      f == gemspec || f.end_with?('.gem') || f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end

