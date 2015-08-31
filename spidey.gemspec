# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'spidey/version'

Gem::Specification.new do |s|
  s.name        = 'spidey'
  s.version     = Spidey::VERSION
  s.authors     = ['Joey Aghion']
  s.email       = ['joey@aghion.com']
  s.homepage    = 'https://github.com/joeyAghion/spidey'
  s.summary     = 'A loose framework for crawling and scraping web sites.'
  s.description = 'A loose framework for crawling and scraping web sites.'
  s.license     = 'MIT'

  s.rubyforge_project = 'spidey'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop', '0.33.0'

  s.add_runtime_dependency 'mechanize'
end
