require 'state_machine'

module Travels

  extend Common::ForceConventionalNaming

  module States

    module StateMachine

      # TRANSITIONS = {
      #
      #   # Taking the travel
      #   :submitted => :taken,
      #
      #   :taken => [
      #     # Withdrawing previously taken travel
      #     :submitted,
      #
      #     # Completing the travel
      #     :completed
      #   ]
      # }

    end

    class AbstractState < ActiveRecord::Base

      # Define table-name
      self.table_name = "travels_states_log"

      module SubclassCollector
        extend ActiveSupport::Concern

        SUBCLASSES = []

        included do
          def self.inherited(subclass)
            super # Oh, god, this is a must
                  # Lacking accuracy of tricking with `inherited` hooks inside
                  # `ActiveRecord` hierarchy may result in the following kind of an
                  # errors:
                  #
                  #   NoMethodError (undefined method `synchronize' for nil:NilClass)

            SUBCLASSES << subclass
          end
        end
      end

      include SubclassCollector


      module Helpers
        extend ActiveSupport::Concern

        #
        # FIXME
        # Load all state classes eagerly to properly initialize
        # dependent harness
        #
        Travels::States::Canceled
        Travels::States::Completed
        Travels::States::Submitted
        Travels::States::Taken
        Travels::States::Withdrawn

        Travels::States::AbstractState::SUBCLASSES.each do |state|
          self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{state.name.demodulize.downcase}?
              send(:type).eql?(#{state}.name)
            end
          RUBY_EVAL
        end
      end

      include Helpers


      #
      # State machine
      #
      include StateMachine

      #
      # Travels
      #

      # Make self loggable in `Travels::Travel`

      # FIXME
      Travels::Logs::Log
      Travels::Logs.make(self, :loggable, in: Travels::Travel)


      def to_s
        self.class.name.to_s
      end

      #
      # Plunges helpers of use inside class possessing state
      #
      module ExportMethods
        Travels::States::AbstractState::SUBCLASSES.each do |state|
          name = state.name.demodulize.downcase
          self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{name}?
              state.send(:#{name}?)
            end
          RUBY_EVAL
        end
      end

    end

  end

end