module ActiveFedora::Aggregation
  module BaseExtension

    ##
    # Create an aggregation association on the class
    # @example
    #   class Image < ActiveFedora::Base
    #     aggregates :generic_files
    #   end
    def aggregates(name, options={})
      Builder.build(self, name, options)
    end

    def create_reflection(macro, name, options, active_fedora)
      if macro == :aggregation
        Reflection.new(macro, name, options, active_fedora).tap do |reflection|
          add_reflection name, reflection
        end
      else
        super
      end
    end
  end
end
