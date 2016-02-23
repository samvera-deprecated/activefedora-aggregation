# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_fedora/aggregation/version'

Gem::Specification.new do |spec|
  spec.name          = "activefedora-aggregation"
  spec.version       = ActiveFedora::Aggregation::VERSION
  spec.authors       = ["Justin Coyne"]
  spec.email         = ["justin@curationexperts.com"]

  spec.summary       = %q{Aggregations for active-fedora}
  spec.homepage      = "http://github.org/curationexperts/activefedora-aggregation"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'active-fedora', '~> 9.9'
  spec.add_dependency 'rdf-vocab', '~> 0.8.1'
  # Avoid RDF 1.1.17 because of a bug from ruby 2.2
  # https://github.com/ruby-rdf/rdf/pull/213
  spec.add_dependency 'rdf', '~> 1.1', '>= 1.1.17.1'

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "solr_wrapper", "~> 0.4"
  spec.add_development_dependency 'fcrepo_wrapper', '~> 0.2'
end
