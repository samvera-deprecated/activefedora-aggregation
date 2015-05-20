module ActiveFedora::Aggregation
  module BaseExtension
    extend ActiveSupport::Concern
    include PersistLinks

    module ClassMethods
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

      def setup_persist_links_callback(reflection)
        save_method = :"autosave_aggregation_links_for_#{reflection.name}"
        define_non_cyclic_method(save_method, reflection) { persist_aggregation_links }

        # Doesn't use after_save because we need this callback to come after the autosave callback
        after_create save_method
        after_update save_method
      end
    end
  end
end
