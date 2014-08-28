module Api
  module V1

    class StatesController < ApplicationController

      restrict_access :activate, :inactivate

      #
      # TODO: CHOKE UP THIS BREACH ASAP
      #
      skip_before_action :verify_authenticity_token, only: [ :activate, :deactivate ]

      def activate
        r = current_user.active!
        respond_with r
      end

      def deactivate
        r = current_user.inactive!
        respond_with r
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
