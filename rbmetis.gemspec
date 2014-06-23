# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbmetis/version'

Gem::Specification.new do |spec|
  spec.name          = "rbmetis"
  spec.version       = RbMetis::VERSION
  spec.authors       = ["Masahiro TANAKA"]
  spec.email         = ["masa16.tanaka@gmail.com"]
  spec.summary       = %q{FFI wrapper of METIS graph partitioning library}
  spec.description   = %q{FFI wrapper of METIS graph partitioning library version: 5.1.0 http://www.cs.umn.edu/~metis/}
  spec.homepage      = "https://github.com/masa16/rbmetis"
  spec.license       = "Apache License 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/extconf.rb"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "ffi"
end
