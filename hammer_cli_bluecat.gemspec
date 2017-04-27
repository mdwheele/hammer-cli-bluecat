# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hammer_cli_bluecat/version'

Gem::Specification.new do |spec|
  spec.name          = "hammer_cli_bluecat"
  spec.version       = HammerCliBluecat::VERSION
  spec.authors       = ["Dustin Wheeler"]
  spec.email         = ["mdwheele@ncsu.edu"]

  spec.summary       = %q{Bluecat commands for Hammer}
  spec.description   = %q{Bluecat commands for Hammer CLI}
  spec.homepage      = "https://github.com/mdwheele/hammer_cli_bluecat"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'bluecat', '~> 0.1'
  spec.add_dependency 'foreman_api', '~> 0.1'
  spec.add_dependency 'netaddr', '~> 1.5'
  spec.add_dependency 'hammer_cli', '~> 0.10'
  spec.add_dependency 'hammer_cli_foreman', '~> 0.10'
  spec.add_dependency 'apipie-bindings', '~> 0.2'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
