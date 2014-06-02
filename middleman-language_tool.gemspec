# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-language_tool/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-language_tool"
  spec.version       = Middleman::LanguageTool::VERSION
  spec.authors       = ["Ivan Zarea"]
  spec.email         = ["zarea.ion@gmail.com"]
  spec.description   = %q{Run spell checks as a build phase in middleman}
  spec.summary       = %q{Run spell checks as a build phase in middleman}
  spec.homepage      = "https://www.github.com/skade/middleman-language_tool"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "middleman-core", ["~> 3.2"]
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "language_tool"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
