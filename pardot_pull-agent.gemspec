version = ENV["RUBYGEM_VERSION"]
if version.to_s.empty?
  abort "Please set the gem version via the RUBYGEM_VERSION environment variable."
end

Gem::Specification.new do |s|
  s.name = "pardot_pull-agent"
  s.version = ENV["RUBYGEM_VERSION"]
  s.summary = "Pardot code deploy agent."
  s.description = s.summary
  s.homepage = "https://confluence.dev.pardot.com/display/PTechops/Pull-based+Deployment+Overview"
  s.email = "pd-bread@salesforce.com"
  s.authors = ["https://confluence.dev.pardot.com/display/PTechops/BREAD+Ops"]
  s.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  s.executables = ["pull-agent"]
  s.add_dependency "artifactory", "~>2.3"
  s.add_development_dependency "byebug", "~>8.2"
  s.add_development_dependency "rake", "~>10.4"
  s.add_development_dependency "rspec", "~>3.4"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "webmock", "~>1.21"
end
