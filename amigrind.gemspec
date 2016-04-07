# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'amigrind/version'

Gem::Specification.new do |spec|
  spec.name          = "amigrind"
  spec.version       = Amigrind::VERSION
  spec.authors       = ["Ed Ropple"]
  spec.email         = ["ed@edropple.com"]

  spec.summary       = "An easy, convention-over-configuration builder for Packer images."
  spec.homepage      = "https://github.com/eropple/amigrind"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency 'cri', '~> 2.7.0'
  spec.add_runtime_dependency 'os', '~> 0.9.6'
  spec.add_runtime_dependency 'racker', '~> 0.2.0'
  spec.add_runtime_dependency 'virtus', '~> 1.0.5'
  spec.add_runtime_dependency 'activesupport', '~> 4.2.6'
  spec.add_runtime_dependency 'activemodel', '~> 4.2.6'
  spec.add_runtime_dependency 'erubis', '~> 2.7.0'
  spec.add_runtime_dependency 'ptools', '~> 1.3', '>= 1.3.3'
  spec.add_runtime_dependency 'settingslogic', '~> 2.0.9'

  spec.add_runtime_dependency 'amigrind-core'
end
