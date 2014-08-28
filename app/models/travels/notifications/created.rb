module Travels

  extend Common::ForceConventionalNaming

  module Notifications

    class Created < TravelNotification

      after_commit :push, on: :create

      private

        # FIXME

        def push
          # Forward PUSHes only to those having deliberately confirmed
          # to get those
          receivers = Users::Performer.active
          rids = receivers.map { |p| p.subscription }.compact.map { |s| s.rid }

          PushHelper::push({ message: message }, *rids)
        end

      # extend Events::Manager::ClassMethods

    end

  end
end
