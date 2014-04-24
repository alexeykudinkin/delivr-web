module Travels

  extend Common::ForceConventionalNaming

  class State < ActiveRecord::Base

    def self.taken
      State.new({ taken: true,  completed: false, withdrawn: false })
    end

    def self.completed
      State.new({ taken: true,  completed: true,  withdrawn: false })
    end

    def self.withdrawn
      State.new({ taken: false, completed: false, withdrawn: true })
    end


    belongs_to  :travel,
                :class_name => Travel,
                :inverse_of => :state

    def to_s
      if send(:completed)
        "completed"
      elsif send(:taken)
        "taken"
      elsif send(:withdrawn)
        "withdrawn"
      else
        "submitted"
      end
    end

  end

end