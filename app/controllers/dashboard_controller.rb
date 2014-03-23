class DashboardController < ApplicationController

  # GET /dashboard
  def show
    @travels = Travels::Travel.submitted

    respond_to do |format|
      format.html # dashboard/show.html.erb
    end
  end

end
