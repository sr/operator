Gem::Specification.new do |spec|
  spec.name          = "lita-zabbix"
  spec.version       = "0.1.0"
  spec.authors       = ["Pardot BREAD Team"]
  spec.email         = ["pd-bread@salesforce.com"]
  spec.description   = "Lita Zabbix client"
  spec.summary       = "Lita Zabbix client"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  spec.add_runtime_dependency "zabbixapi", "~> 2.4", ">= 2.4.6"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
