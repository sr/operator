Gem::Specification.new do |s|
  s.name = "pardot-rubylib"
  s.summary = ""
  s.description = ""
  s.version = "1"
  s.homepage = "https://confluence.dev.pardot.com/display/PTechops/Pull-based+Deployment+Overview"
  s.email = "pd-bread@salesforce.com"
  s.authors = ["https://confluence.dev.pardot.com/display/PTechops/BREAD+Ops"]
  s.files += Dir.glob("lib/**/*")
  s.files << "pardot-rubylib.gemspec"
  s.add_dependency "lograge", "0.3.6"
  s.add_dependency "scrolls", "0.3.8"
  s.add_dependency "logstash-event", "1.2.02"
  s.add_development_dependency "minitest"
end
