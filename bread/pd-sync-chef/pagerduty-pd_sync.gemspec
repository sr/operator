# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'pagerduty-pd_sync'
  spec.version       = '0.1.3'
  spec.authors       = ['Tim Heckman']
  spec.email         = ['ops+pd_sync@pagerduty.com']
  spec.licenses      = ['Apache 2.0']

  spec.summary       = 'A knife plugin to support the PagerDuty Chef workflow'
  spec.description   = 'A knife plugin to support the PagerDuty Chef workflow'
  spec.homepage      = 'https://github.com/PagerDuty/pd-sync-chef'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1.4'

  spec.add_runtime_dependency 'chef', '~> 12'
  spec.add_runtime_dependency 'berkshelf', '~> 4'
  spec.add_runtime_dependency 'json', '~> 1'

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'rake', '~> 11'
  spec.add_development_dependency 'rspec', '~> 3'
end
