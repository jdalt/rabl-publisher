$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "publisher/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "publisher"
  s.version     = Publisher::VERSION
  s.authors     = ["Jacob Dalton"]
  s.email       = ["jacobrdalton@gmail.com"]
  s.homepage    = "http://www.jacobrdalton.com"
  s.summary     = "Gem to push updates to external database from rails."
  s.description = "Description of Publisher."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.16"
  s.add_dependency "resque", "~> 1.25"
  s.add_dependency "resque-retry"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry"
end
