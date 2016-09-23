# -*- encoding: utf-8 -*-
# stub: sql-parser 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "sql-parser"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Dray Lacy", "Louis Mullie"]
  s.date = "2016-09-23"
  s.description = " A Racc-based Ruby parser and generator for SQL statements "
  s.email = ["dray@izea.com", "louis.mullie@gmail.com"]
  s.files = ["lib/sql-parser", "lib/sql-parser.rb", "lib/sql-parser/parser.racc", "lib/sql-parser/parser.racc.rb", "lib/sql-parser/parser.rex", "lib/sql-parser/parser.rex.rb", "lib/sql-parser/sql_visitor.rb", "lib/sql-parser/statement.rb", "lib/sql-parser/version.rb"]
  s.homepage = "https://github.com/louismullie/sql-parser"
  s.rubygems_version = "2.5.1"
  s.summary = "Ruby library for parsing and generating SQL statements"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<racc>, ["~> 1.4"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rexical>, ["~> 1.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<pry-byebug>, [">= 0"])
    else
      s.add_dependency(%q<racc>, ["~> 1.4"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rexical>, ["~> 1.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<pry-byebug>, [">= 0"])
    end
  else
    s.add_dependency(%q<racc>, ["~> 1.4"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rexical>, ["~> 1.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<pry-byebug>, [">= 0"])
  end
end
