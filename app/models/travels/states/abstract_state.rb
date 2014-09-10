require 'state_machine'

module Travels

  extend Common::ForceConventionalNaming

  module States

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

        module Presentation
          module ClassMethods
            # Stringify
            def present
              name.demodulize.downcase
            end

            # Symbolize
            def sym
              present.to_sym
            end
          end

          def to_s
            self.class.present
          end

          def to_sym
            self.class.sym
          end
        end

        include Presentation

      end

      include Helpers


      #
      # State machine
      #
      module StateMachine
        extend ActiveSupport::Concern

        included do
          # attr_accessor :stateX

          # state_machine :stateX, initial: :submitted do
          state_machine :state, initial: :submitted do

            event :take do
              transition [ :submitted, :withdrawn ] => :taken
            end

            event :cancel do
              transition :submitted => :canceled
            end

            event :complete do
              transition :taken => :completed
            end

            event :withdraw do
              transition :taken => :withdrawn
            end

            #
            # All travel states involved
            #

            AbstractState::SUBCLASSES.each do |klass|
              state klass.sym, value: lambda { klass.new }, if: lambda { |s| s.is_a? klass }
            end
          end
        end

      end

      #
      # Travels
      #

      # Make self loggable in `Travels::Travel`

      # FIXME
      Travels::Logs::Log
      Travels::Logs.make(self, :loggable, in: Travels::Travel)

    end

  end

end