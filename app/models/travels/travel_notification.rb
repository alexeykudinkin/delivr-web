module Travels

  class TravelNotification < ActiveRecord::Base

    belongs_to :travel,
               :class_name => Travel,
               :inverse_of => :notifications

    class << self

      def taken_by(performer)
        create({
                 status: "Taken by #{performer.id}"
               })
      end

    end

  end

end
