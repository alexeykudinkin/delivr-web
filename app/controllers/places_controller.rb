
class PlacesController < ApplicationController

  restrict_access :arrive

  def arrive
    attrs = whitelist(params, :arrive)

    place = Travels::Places::Destination.find(attrs[:id])

    # Assure some invariants:
    # Performer should have taken the travel this place belongs to

    unless place.travel.performer == current_user
      fail(:json, :forbidden, "Only performer may report being arrived to this destination!") and return
    end

    # NOTE:
    # Should we impose that destinations are visited in particular order

    respond_to do |format|
      format.json { render status: :ok, json: "Ok" }
    end
  end

  protected

    def whitelist(params, action)
      case action
        when :arrive
          params.permit(:id)

        else
          raise "Unknown action: #{action}!"
      end
    end

end