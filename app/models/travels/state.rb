module Travels

  extend Common::ForceConventionalNaming

  class State < ActiveRecord::Base

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