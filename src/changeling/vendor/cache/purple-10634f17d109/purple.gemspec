# -*- encoding: utf-8 -*-
# stub: purple 1.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "purple"
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Heroku"]
  s.date = "2016-03-16"
  s.description = "Purple theme"
  s.email = ["fnando.vieira@gmail.com"]
  s.files = [".gitignore", ".jshintrc", "CHANGELOG.md", "Gemfile", "Gemfile.lock", "Procfile", "README.md", "bower.json", "dist/css/purple.css", "dist/css/purple.min.css", "dist/js/purple.js", "dist/js/purple.min.js", "docs/_harp.json", "docs/_layout.ejs", "docs/dist", "docs/gradients.ejs", "docs/images/Group.png", "docs/images/collaborators-1.png", "docs/images/creditcard.png", "docs/images/cube.png", "docs/images/domains.png", "docs/images/editing-rows-modal.png", "docs/images/editing-rows-remove.png", "docs/images/editing-rows.png", "docs/images/fav-inactive.png", "docs/images/fav.png", "docs/images/favicon.ico", "docs/images/footer-img.png", "docs/images/globe.png", "docs/images/modal-1.png", "docs/images/modal-2.png", "docs/images/profile-1.png", "docs/images/profile-edit.gif", "docs/images/pryimid.png", "docs/images/remove-row-item.gif", "docs/images/ssh-1.png", "docs/images/ssh-2.png", "docs/images/ssh-add.gif", "docs/index.ejs", "docs/js/scroll.js", "docs/js/stickyNav.js", "docs/lists.ejs", "docs/modal.ejs", "docs/styles.scss", "gulpfile.js", "js/purple.js", "lib/purple.rb", "package.json", "purple.gemspec", "rails/purple/_bootstrap-sprockets.scss", "rails/purple/bootstrap-sprockets.js", "rails/purple/rails.js", "rails/purple/rails.scss", "sass/purple.scss", "sass/purple/_alerts.scss", "sass/purple/_buttons.scss", "sass/purple/_code.scss", "sass/purple/_dropdowns.scss", "sass/purple/_forms.scss", "sass/purple/_gradients.scss", "sass/purple/_list-group.scss", "sass/purple/_mixins.scss", "sass/purple/_modals.scss", "sass/purple/_nav-pills.scss", "sass/purple/_purple-box.scss", "sass/purple/_scaffolding.scss", "sass/purple/_spinner.scss", "sass/purple/_sub-nav.scss", "sass/purple/_tables.scss", "sass/purple/_type.scss", "sass/purple/_variables.scss", "sass/purple/utils/_border.scss", "sass/purple/utils/_space.scss", "sass/purple/utils/_state.scss", "sass/purple/utils/_type.scss"]
  s.homepage = "https://github.com/heroku/purple"
  s.rubygems_version = "2.5.1"
  s.summary = "Purple theme"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 0"])
      s.add_runtime_dependency(%q<bootstrap-sass>, ["~> 3.3.5"])
      s.add_runtime_dependency(%q<bourbon>, ["~> 4.2.3"])
      s.add_runtime_dependency(%q<autoprefixer-rails>, [">= 0"])
      s.add_development_dependency(%q<foreman>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 0"])
      s.add_dependency(%q<bootstrap-sass>, ["~> 3.3.5"])
      s.add_dependency(%q<bourbon>, ["~> 4.2.3"])
      s.add_dependency(%q<autoprefixer-rails>, [">= 0"])
      s.add_dependency(%q<foreman>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 0"])
    s.add_dependency(%q<bootstrap-sass>, ["~> 3.3.5"])
    s.add_dependency(%q<bourbon>, ["~> 4.2.3"])
    s.add_dependency(%q<autoprefixer-rails>, [">= 0"])
    s.add_dependency(%q<foreman>, [">= 0"])
  end
end
