module Travels

  extend Common::ForceConventionalNaming

  module Logs

    def self.make(klass, what, options)
      sanitize(klass)
      case what
        when :logs
          sanitize(options[:what])
          klass.include Log.imbue(options[:what])
        when :loggable
          sanitize(options[:in])
          klass.include Loggable.imbue(options[:in])
        else
          raise "Unknown option!"
      end
    end

    private

      def self.sanitize(klass)
        raise TypeError.new("May not imbue states in classes other than `ActiveRecord::Base` subclasses") unless klass < ActiveRecord::Base
      end

      module ClassHolder
        def assoc_class
          @_assoc_class0
        end

        def imbue(klass)
          @_assoc_class0 = klass
          self
        end

        private
          mattr_accessor :_assoc_class0
      end

      module Log
        extend ActiveSupport::Concern
        extend ClassHolder

        included do
          has_many    :loggables,
                      :class_name => Log.assoc_class,
                      :inverse_of => :log,
                      :autosave   => true
        end
      end

      module Loggable
        extend ActiveSupport::Concern
        extend ClassHolder

        included do
          belongs_to  :log,
                      :class_name => Loggable.assoc_class,
                      :inverse_of => :loggables
        end
      end

  end
end