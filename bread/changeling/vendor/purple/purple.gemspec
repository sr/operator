require 'json'

Gem::Specification.new do |spec|
  bower = JSON.load(File.read(File.expand_path('../bower.json', __FILE__)))

  spec.name          = 'purple'
  spec.version       = bower['version']
  spec.authors       = ['Heroku']
  spec.email         = ['fnando.vieira@gmail.com']
  spec.summary       = 'Purple theme'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/heroku/purple'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rails'
  spec.add_dependency 'bootstrap-sass', '~> 3.3.5'
  spec.add_dependency 'bourbon', '~> 4.2.3'
  spec.add_dependency 'autoprefixer-rails'

  spec.add_development_dependency 'foreman'
end
