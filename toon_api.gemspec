# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toon_api/version'

Gem::Specification.new do |spec|
  spec.name          = "toon_api"
  spec.version       = ToonApi::VERSION
  spec.authors       = ["Maarten van Vliet"]
  spec.email         = ["maartenvanvliet@gmail.com"]

  spec.summary       = %q{Gem to interface with Eneco Toon api}
  spec.description   = %q{Gem to interface with Eneco Toon api. Port of https://github.com/rvdm/toon}
  spec.homepage      = "https://github.com/maartenvanvliet/toon_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.0"
end
