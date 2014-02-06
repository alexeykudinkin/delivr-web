class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #
  # Fence actions that require user to be logged in prior
  # to executing them
  #

  def self.fenced
    @_fenced_actions ||= []
  end

  #
  # Registers filter to query session state for checking
  # whether user is logged in
  #

  def self.require_login(*actions)
    fenced.concat [ *actions ]

    before_action only: fenced do |controller|
      require_login(controller)
    end
  end

  def require_login(controller)
    unless controller.send(:logged_in?)
      redirect_to login_path, status: :forbidden, flash: { error: 'You must be logged in!' }
    end
  end


  # Helpers

  module Helpers

    def current_user
      @_current_user ||= Users::User.find_by(session[:user])
    end

    def logged_in?
      not current_user.blank?
    end

  end

  #include Helpers

  def current_user
    @_current_user ||= Users::User.find(session[:user]) if session[:user]
  end

  def logged_in?
    !current_user.blank?
  end

  helper_method :current_user, :logged_in?

end
