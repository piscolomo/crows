require "./lib/crows"

Gem::Specification.new do |s|
  s.name              = "crows"
  s.version           = Crows::VERSION
  s.summary           = "Micro library for authorization in Ruby classes."
  s.description       = "Crows is a micro framework-agnostic library for authorization in Ruby classes. A set of crows to authorized your users, because the night is dark and full of terrors... Crows provide you with a few helpers to check if `current_user` can make operations into some records. This gives you the freedom to build your own plain Ruby classes to make authorization works easily, without the painful of bigs DSLs or something like that."
  s.authors           = ["Julio Lopez"]
  s.email             = ["ljuliom@gmail.com"]
  s.homepage          = "http://github.com/TheBlasfem/crows"
  s.files = Dir[
    "LICENSE",
    "README.md",
    "lib/**/*.rb",
    "*.gemspec",
    "test/**/*.rb"
  ]
  s.license           = "MIT"
  s.add_development_dependency "cutest", "1.1.3"
end