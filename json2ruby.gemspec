# -*- encoding: utf-8 -*-
require File.expand_path('../lib/json2ruby/version', __FILE__)

Gem::Specification.new do |s|  
  s.authors       = ["Tom Cully"]
  s.email         = ["tomhughcully@gmail.com"]
  s.summary       = 'A ruby rool for generating POROs from JSON data'
  s.description   = 'json2ruby is intended to generate ruby model classes/modules from existing JSON data, e.g. responses from an API.'
  s.homepage      = "http://github.com/tomdionysus/json2ruby"

  s.files         = `git ls-files`.split($\)
  s.executables   = ["json2ruby"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = "json2ruby"
  s.require_paths = ["lib"]
  s.version       = JSON2Ruby::VERSION

  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency 'simplecov',        '~> 0.10.0'
  s.add_development_dependency 'simplecov-rcov',   '~> 0.2'
  s.add_development_dependency 'rdoc',             '~> 4.1'
  s.add_development_dependency 'sdoc',             '~> 0.4'
  s.add_development_dependency 'rspec',            '~> 3.1'
  s.add_development_dependency 'rspec-mocks',      '~> 3.1'
end  