module ActiveFedora
  module Orders
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :AggregationBuilder
      autoload :Association
      autoload :Builder
      autoload :CollectionProxy
      autoload :Reflection
      autoload :ListNode
      autoload :OrderedList
    end
  end
end
