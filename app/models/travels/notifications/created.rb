module Travels

  extend Common::ForceConventionalNaming

  module Notifications

    class Created < TravelNotification

      after_commit :push, on: :create

      private

        # FIXME

        def push
          receivers = Users::Performer.all.map { |p| p.subscription }.compact.map { |s| s.rid }
          PushHelper::push({ message: message }, *receivers)
        end

      # extend Events::Manager::ClassMethods

    end

  end
end
