Gem::Specification.new do |gem|
  gem.name          = 'fluent-plugin-tai64n_parser'
  gem.version       = '0.0.1'
  gem.authors       = ['Akira Maeda']
  gem.email         = ['glidenote+github@gmail.com']
  gem.homepage      = 'https://github.com/glidenote/fluent-plugin-tai64n_parser'
  gem.description   = %q{Fluentd plugin to parse the tai64n format log.}
  gem.summary       = %q{Fluentd plugin to parse the tai64n format log.}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'fluentd'
  gem.add_development_dependency 'test-unit'

  gem.add_runtime_dependency     'fluentd'
end
