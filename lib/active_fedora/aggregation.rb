require 'active_fedora/aggregation/version'
require 'active_support'
require 'active-fedora'
require 'rdf-vocab'

module ActiveFedora
  module Aggregation
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :Aggregator
      autoload :FileAssociation
      autoload :Proxy
      autoload :Builder
    end
  end
end
