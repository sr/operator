# -*- encoding: utf-8 -*-
# stub: sql-parser 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "sql-parser".freeze
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dray Lacy".freeze, "Louis Mullie".freeze]
  s.date = "2017-02-22"
  s.description = " A Racc-based Ruby parser and generator for SQL statements ".freeze
  s.email = ["dray@izea.com".freeze, "louis.mullie@gmail.com".freeze]
  s.files = ["lib/sql-parser".freeze, "lib/sql-parser.rb".freeze, "lib/sql-parser/parser.racc".freeze, "lib/sql-parser/parser.racc.rb".freeze, "lib/sql-parser/parser.rex".freeze, "lib/sql-parser/parser.rex.rb".freeze, "lib/sql-parser/sql_visitor.rb".freeze, "lib/sql-parser/statement.rb".freeze, "lib/sql-parser/version.rb".freeze]
  s.homepage = "https://github.com/louismullie/sql-parser".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Ruby library for parsing and generating SQL statements".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<racc>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<rexical>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
    else
      s.add_dependency(%q<racc>.freeze, ["~> 1.4"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<rexical>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<racc>.freeze, ["~> 1.4"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rexical>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
  end
end
