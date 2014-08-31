class DashboardController < ApplicationController

  restrict_access :show

  # GET /dashboard
  def show
    @travels = Travels::Travel.where(customer: current_user)

    respond_to do |format|
      format.html # dashboard/show.html.erb
    end
  end

end
