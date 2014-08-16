module App

  class SubscriberController < ApplicationController

    restrict_access :subscribe

    #
    # TODO: CHOKE UP THIS BREACH ASAP
    #
    skip_before_action :verify_authenticity_token, only: [ :subscribe ]


    def subscribe
      rid = whitelist(params, :subscribe)
      current_user.becomes(Users::Performer).subscription = Communication::Push::GCM.new(rid: rid)
    end

    private

      def whitelist(params, action)
        case action
          when :subscribe
            params.require(:id)
          else
            raise "Unknown action: #{action}"
        end
      end

  end

end