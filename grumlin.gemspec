# frozen_string_literal: true

require_relative "lib/grumlin/version"

Gem::Specification.new do |spec|
  spec.name          = "grumlin"
  spec.version       = Grumlin::VERSION
  spec.authors       = ["Gleb Sinyavskiy"]
  spec.email         = ["zhulik.gleb@gmail.com"]

  spec.summary       = "Gremlin query language DSL for Ruby."
  spec.description   = "Gremlin query language DSL for Ruby."
  spec.homepage      = "https://github.com/zhulik/grumlin"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zhulik/grumlin"
  spec.metadata["changelog_uri"] = "https://github.com/zhulik/grumlin/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "async-pool", "~> 0.3"
  spec.add_dependency "async-websocket", "~> 0.19"
end
