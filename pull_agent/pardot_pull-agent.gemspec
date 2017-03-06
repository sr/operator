version = ENV["RUBYGEM_VERSION"]
if version.to_s.empty?
  version = "0.pre"
end

Gem::Specification.new do |s|
  s.name = "pardot_pull-agent"
  s.version = version
  s.summary = "Pardot code deploy agent."
  s.description = s.summary
  s.homepage = "https://confluence.dev.pardot.com/display/PTechops/Pull-based+Deployment+Overview"
  s.email = "pd-bread@salesforce.com"
  s.authors = ["https://confluence.dev.pardot.com/display/PTechops/BREAD+Ops"]
  s.files += ["README.md"]
  s.files += Dir.glob("environments/*")
  s.files += Dir.glob("lib/**/*")
  s.executables = ["pull-agent", "pull-agent-knife", "pa-deploy-chef"]
  s.add_dependency "logstash-event", "1.2.02"
  s.add_dependency "scrolls", "0.3.8"
  s.add_dependency "redis", "~>3.3"
  s.add_development_dependency "byebug", "~>8.2"
  s.add_development_dependency "rake", "~>10.4"
  s.add_development_dependency "rspec", "~>3.4"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "webmock", "~>2.1"
end
