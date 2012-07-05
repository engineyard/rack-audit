# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack-audit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["EngineYard"]
  gem.email         = ["engineering@engineyard.com"]
  gem.description   = %q{Asynchronously send requests to another system}
  gem.summary       = %q{Asynchronously send requests to another system}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-audit"
  gem.require_paths = ["lib"]
  gem.version       = Rack::Audit::VERSION

  gem.add_dependency 'rack'
  gem.add_dependency 'uuidtools'
  gem.add_dependency 'multi_json'
end
