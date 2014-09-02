module Travels

  class DueDate < ActiveRecord::Base

    module DateUtils
      extend ActiveSupport::Concern

      module ClassMethods
        def local(datetime)
          datetime.strftime("%F %R")
        end
      end
    end

    include DateUtils


    belongs_to :destination,
               :class_name => Places::Destination,
               :inverse_of => :due_date

    # Getters for the due-date time-bounds expressed
    # in millis since the epoch

    def starts
      DueDate.local(super.to_datetime)
    end

    def ends
      DueDate.local(super.to_datetime)
    end


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