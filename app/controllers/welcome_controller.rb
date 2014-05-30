class WelcomeController < ApplicationController

  protect_from_forgery

  def index
    render "welcome/index", layout: false
  end

end