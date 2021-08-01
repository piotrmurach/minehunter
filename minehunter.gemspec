# frozen_string_literal: true

require_relative "lib/minehunter/version"

Gem::Specification.new do |spec|
  spec.name          = "minehunter"
  spec.version       = Minehunter::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = "Terminal mine hunting game."
  spec.description   = "Terminal mine hunting game."
  spec.homepage      = "https://github.com/piotrmurach/minehunter"
  spec.license       = "AGPL-3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/minehunter/issues"
  spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/minehunter/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/minehunter"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/minehunter"

  spec.files         = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.bindir        = "exe"
  spec.executables   = ["minehunter", "minehunt"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
