require 'active_fedora/aggregation/version'
require 'active_support'
require 'active-fedora'
require 'rdf/vocab'
require 'active_fedora/filter'
require 'active_fedora/orders'

module ActiveFedora
  module Aggregation
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :Proxy
      autoload :BaseExtension
      autoload :OrderedReader
      autoload :ListSource
    end

    ActiveFedora::Base.include BaseExtension
  end
end
