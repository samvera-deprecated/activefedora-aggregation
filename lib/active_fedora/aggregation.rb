require 'active_fedora/aggregation/version'
require 'active_support'
require 'active-fedora'
require 'rdf/vocab'

module ActiveFedora
  module Aggregation
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :Association
      autoload :Proxy
      autoload :Builder
      autoload :Reflection
      autoload :BaseExtension
      autoload :OrderedReader
      autoload :LinkInserter
    end

    ActiveFedora::Base.extend BaseExtension
  end
end
