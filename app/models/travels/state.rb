module Travels

  extend Common::ForceConventionalNaming

  class State < ActiveRecord::Base

    STATES = [
      :submitted,   # DEFAULT

      :taken,       # Taken by performer
      :completed,   # Completed in full by performer
      :cancelled,   # Cancelled by the customer
      :withdrawn    # Withdrawn by the performer (prior taken by)
    ]

    self.table_name = "travel_states"

    module Instances
      extend ActiveSupport::Concern

      Travels::State::STATES.each do |state|
        self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{state.to_s}?
            send(:status).to_sym == :#{state}
          end
        RUBY_EVAL
      end

      included do |klass|

        klass.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def self.get(state)
            values = STATES
            case state
              #{STATES.reduce("") do |_case, state|
                  _case +=
                    "when :#{state}
                              unless @#{state} ||= State.find_by(status: :#{state})
                                @#{state} = State.create(status: :#{state})
                              end
                              @#{state}\n"
                end
              }
              else
                nil
            end
          end
        RUBY_EVAL

      end

    end

    # Plunges helpers of use inside class possessing state
    module ExportMethods

      Travels::State::STATES.each do |state|
        self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{state.to_s}?
            state.send(:#{state}?)
          end
        RUBY_EVAL
      end

    end

    include Instances


    has_many    :travels,
                :class_name => Travel,
                :inverse_of => :state

    def to_s
      self.status.to_s
    end

  end

end