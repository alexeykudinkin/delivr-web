class DashboardController < ApplicationController

  restrict_access :show

  # GET /dashboard
  def show
    if current_user.role.is_a?(Users::Roles::Admin)
      @travels = Travels::Travel.all
    else
      @travels = Travels::Travel.where(customer: current_user)
    end

    respond_to do |format|
      format.html # dashboard/show.html.erb
    end
  end

end
