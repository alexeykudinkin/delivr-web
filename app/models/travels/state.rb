module Travels

  extend Common::ForceConventionalNaming

  class State < ActiveRecord::Base

    module Instances

      # def self.taken
      #   State.new({ taken: true,  completed: false, withdrawn: false })
      # end
      #
      # def self.completed
      #   State.new({ taken: true,  completed: true,  withdrawn: false })
      # end
      #
      # def self.withdrawn
      #   State.new({ taken: false, completed: false, withdrawn: true })
      # end

      def self.get(state)
        case state
          when :taken
            @taken      ||= State.new({ taken: true,  completed: false, withdrawn: false })
          when :completed
            @completed  ||= State.new({ taken: true,  completed: true,  withdrawn: false })
          when :withdrawn
            @withdrawn  ||= State.new({ taken: false, completed: false, withdrawn: true })
          else
            nil
        end
      end

    end


    # Plunges helpers of use inside class possessing state
    module ExportMethods

      [ :taken, :completed, :withdrawn ].each do |state|
        # @_state_m = include?.method(:state)
        self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{state.to_s}?
            state.send(:#{state}?)
          end
        RUBY_EVAL
      end

    end


    # TODO: THIS IS AN ISOLATION LAYER
    #       PENDING TILL REMASTERING

    def taken?
      send(:taken)
    end

    def completed?
      send(:completed)
    end

    def withdrawn?
      send(:withdrawn)
    end


    belongs_to  :travel,
                :class_name => Travel,
                :inverse_of => :state

    def to_s
      if completed?
        "completed"
      elsif taken?
        "taken"
      elsif withdrawn?
        "withdrawn"
      else
        "submitted"
      end
    end

  end

end