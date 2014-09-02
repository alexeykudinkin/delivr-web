module Travels
  module Notifications

    class TravelNotification < ActiveRecord::Base

      belongs_to  :travel,
                  :class_name => Travel,
                  :inverse_of => :notifications

      # extend ClassMethods

    end

    module Helpers

      def created(travel)
        Created.new(message: "New travel! #{travel.route.cost} ₽, #{travel.origin.address}")
      end

      def taken(performer)
        Taken.new(message: "Taken by #{performer.id}")
      end
    end

    extend Helpers

  end
end
