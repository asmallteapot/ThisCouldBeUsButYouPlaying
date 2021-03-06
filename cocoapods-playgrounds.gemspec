# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-playgrounds/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-playgrounds'
  spec.version       = CocoapodsPlaygrounds::VERSION
  spec.authors       = ['Boris Bügling', 'Ellen Teapot']
  spec.email         = ['boris@icculus.org', 'hi@asmallteapot.com']
  spec.summary       = 'Generates a Swift Playground for any Pod.'
  spec.homepage      = 'https://github.com/asmallteapot/cocoapods-playgrounds'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cocoapods', '>= 1.0.0', '< 2.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
