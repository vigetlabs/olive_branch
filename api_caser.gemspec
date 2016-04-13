require "api_caser/version"

Gem::Specification.new do |s|
  s.name        = "api_caser"
  s.version     = ApiCaser::VERSION
  s.summary     = "Handle camel/snake/dash case conversion"
  s.description = "Handle camel/snake/dash case conversion"
  s.authors     = ["Eli Fatsi", "David Eisinger"]
  s.email       = ["eli.fatsi@viget.com", "david.eisinger@viget.com"]
  s.files       = Dir["lib/**/*"] + ["MIT-LICENSE", "README.md"]
  s.homepage    = "https://github.com/vigetlabs/api_caser"
  s.license     = "MIT"
end
