class CoordinatesController < ApplicationController
  require_login :index, :update, :destroy

  def index
    if admin?
      @coordinates = Coordinates.all
    else
      render plain: "404 Not Found", status: 404
    end
  end

  def update
    update_location(whitelist(params))
    render nothing: true
  end

  def destroy
    drop_location
    render nothing: true
  end

  private

    def whitelist(params)
      {
        latitude: params.require(:latitude),
        longitude: params.require(:longitude)
      }
    end
end
