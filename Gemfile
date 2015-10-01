source 'https://rubygems.org'

gem 'rails', '4.2.3'
gem 'mysql2', '~> 0.3', '>= 0.3.18'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails', '~> 4.0', '>= 4.0.4'
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.5.1'
gem 'font-awesome-rails', '3.2.1.3'
gem 'simple_form', '~> 3.1', '>= 3.1.1'
gem 'nested_form', '~> 0.3', '>= 0.3.2'

gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'octokit', '~> 3.8'
gem 'artifactory', '~> 2.3'
gem 'omniauth', '~> 1.2', '>= 1.2.2'
gem 'omniauth-google-oauth2', '~> 0.2', '>= 0.2.6'

gem 'nokogiri', '~> 1.6', '>= 1.6.6.2'

gem 'parallel', '~> 1.6', '>= 1.6.1'

group :development do
  gem 'foreman', '0.78.0'
end

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec-rails', '~> 3.3', '>= 3.3.3'
  gem 'capybara', '~> 2.4', '>= 2.4.4'
  gem 'factory_girl_rails', '~> 4.5'
end

group :test do
  gem 'webmock', '~> 1.21', '>= 1.21.0'
end

group :production, :"app.dev" do
  gem 'therubyracer', '~> 0.12', '>= 0.12.2'
end
