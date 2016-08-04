Gem::Specification.new do |spec|
  spec.name          = "lita-replication-fixing"
  spec.version       = "0.1.0"
  spec.authors       = ["Pardot BREAD Team"]
  spec.email         = ["pd-bread@salesforce.com"]
  spec.description   = "Replication fixing client"
  spec.summary       = "Replication fixing client"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(/^bin/) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  spec.add_runtime_dependency "pagerduty", "2.1.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "webmock", "~> 1.23"
end
