lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "rspec-fuubar"
  spec.version       = "1.0.0"
  spec.authors       = ["Mikael Henriksson", "mhenrixon"]
  spec.email         = ["mikael@mhenrixon.com", "mikael@zoolutions.llc"]
  spec.summary       = "the instafailing RSpec progress bar formatter"
  spec.description   = "the instafailing RSpec progress bar formatter"
  spec.homepage      = "https://github.com/mhenrixon/rspec-fuubar"
  spec.licenses      = ["MIT"]

  spec.executables   = []
  spec.files         = Dir["{app,config,db,lib,templates}/**/*"] + %w[README.md LICENSE.txt]

  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/mhenrixon/rspec-fuubar/issues",
    "changelog_uri" => "https://github.com/mhenrixon/rspec-fuubar/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/mhenrixon/rspec-fuubar/tree/releases/v1.0.0",
    "homepage_uri" => "https://github.com/mhenrixon/rspec-fuubar",
    "source_code_uri" => "https://github.com/mhenrixon/rspec-fuubar",
    "wiki_uri" => "https://github.com/mhenrixon/rspec-fuubar/wiki",
    "rubygems_mfa_required" => "true",
  }

  spec.add_dependency "ostruct"
  spec.add_dependency "rspec-core", ["~> 3.0"]
  spec.add_dependency "ruby-progressbar", ["~> 1.4"]
  spec.add_dependency "stringio"
end
