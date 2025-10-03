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

  spec.files         = Dir["{lib}/**/*", "bin/*", "README.md"]
  spec.executables   = ["deadweight_rails"]
  spec.require_paths = ["lib"]

  spec.add_dependency "parser"
  spec.add_dependency "set"
  spec.add_dependency "colorize"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency 'rspec-rails', '~> 6.0'
end

