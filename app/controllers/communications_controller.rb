class CommunicationsController < ApplicationController

  restrict_access :send0, :text

  module Twilio

    ACCOUNT_SID           = "ACbd91a5a938455e30db504015fe8530cc"
    AUTHENTICATION_TOKEN  = "ea973384bcf779d1deea628c9f61c28b"

    FROM = "+1 304-944-0625" # Berkeley Springs, WV

  end

  # POST
  # /send
  def send0
    attrs = whitelist(params, :send)

    client = ::Twilio::REST::Client.new(Twilio::ACCOUNT_SID, Twilio::AUTHENTICATION_TOKEN)

    to    = attrs[:phone]
    text  = attrs[:text]

    if client.account.messages.create(from: Twilio::FROM, to: to, body: text)
      redirect_to text_path, alert: "Successfully sent!"
    end
  end

  # GET
  # /text
  def text
    respond_to do |format|
      format.html # text.html.erb
    end
  end

  private

    def whitelist(params, action)
      case action
        when :send
          params.require(:recipient)
                .permit(:phone, :text)
        else
          raise "Unknown action: #{action}!"
      end

    end

end