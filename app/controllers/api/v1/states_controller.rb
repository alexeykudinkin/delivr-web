module Api
  module V1

    class StatesController < ApplicationController

      restrict_access :activate, :inactivate

      #
      # TODO: CHOKE UP THIS BREACH ASAP
      #
      skip_before_action :verify_authenticity_token, only: [ :activate, :deactivate ]

      # "Activates" courier, making him ready to get notifications and observe
      # new travels
      #
      # POST /activate
      def activate
        r = current_user.active!
        respond_with r
      end

      # "Deactivates" courier detaching him from notifications (about new travels)
      # and stops him of observing new travels coming
      #
      # POST /deactivate
      def deactivate
        r = current_user.inactive!
        respond_with r
      end

      # Transitions courier into "arrived" state, notifying receiving counter-part
      # of an item being ready to be picked-up
      #
      # POST /arrive
      def arrive
        raise "Implement me!"
      end

      # Transitions courier into "enroute" state, directing him to notify on a regular basis
      # of the travelling progress
      #
      # POST /enroute
      def enroute
        raise "Implement me!"
      end

      private

        def respond_with(state)
          respond_to do |format|
            format.html {
              if state.persisted?
                render json: { status: state.to_s }, status: :ok
              else
                render json: { message: "Failed to switch to #{state} due to #{state.errors.as_json}" }, status: :unprocessable_entity
              end
            }
          end
        end

    end

  end
end
