module Travels

  class DueDate < ActiveRecord::Base

    belongs_to :destination,
               :class_name => Places::Destination,
               :inverse_of => :due_date

    # Getters for the due-date time-bounds expressed
    # in millis since the epoch

    def starts_m
      starts.to_datetime.strftime("%Q")
    end

    def ends_m
      ends.to_datetime.strftime("%Q")
    end

  end

end