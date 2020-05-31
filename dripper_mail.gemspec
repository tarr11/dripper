$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dripper/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dripper_mail"
  s.version     = Dripper::VERSION
  s.authors     = ["Douglas Tarr"]
  s.email       = ["douglas.tarr@gmail.com"]
  s.homepage    = "https://www.github.com/tarr11/dripper"
  s.summary     = "A rails drip email engine"
  s.description = "An opinionated rails drip email engine that depends on ActiveRecord and ActionMailer "
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_runtime_dependency "rails","<= 6"
  s.add_development_dependency "sqlite3", '~> 1.4'
end
