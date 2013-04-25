# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'runt/version'

Gem::Specification.new do |spec|
  spec.name          = "runt"
  spec.version       = Runt::VERSION
  spec.authors       = ["Matthew Lipper"]
  spec.email         = ["mlipper@gmail.com"]
  spec.description   = %q{Runt is a Ruby implementation of temporal patterns by Martin Fowler. Runt provides an API for working with recurring events using set expressions.}
  spec.summary       = %q{Ruby Temporal Expressions}
  spec.homepage      = "http://github.com/mlipper/runt"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
