class Admin::DashboardController < ApplicationController

  restrict_access :show

  #
  # Access checking harness
  #

  def check_whether_have_access
    if current_user.role.blank? || !current_user.role.is_a?(Users::Roles::Admin)
      render status: :forbidden, text: "Ooops! Unfortunately you're not allowed to get here. Sorry! "
    end
  end

  append_before_action do
    check_whether_have_access
  end


  # Actions

  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

end
