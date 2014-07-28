class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  #
  # Fence actions that require user to be logged in prior
  # to executing them
  #

  def self._fenced_actions
    @_fenced_actions ||= []
  end

  #
  # Registers filter to query session state
  # whether user is logged in or not
  #

  def self.require_login(*actions)
    # FIXME
    _fenced_actions.concat [ *actions ]

    prepend_before_action only: _fenced_actions do |controller|
      demand_login(controller)
    end
  end

  def demand_login(controller)
    unless controller.send(:logged_in?)
        redirect_to login_path, status: :forbidden, alert: "You must be logged in!"
    end
  end


  # Helpers

  module UserHelpers

    def current_user
      @_current_user ||= Users::User.find(session[:user]) if session[:user]
    end

    def logged_in?
      !current_user.blank?
    end

  end

  include UserHelpers

  helper_method :current_user, :logged_in?


  #
  # Marks controller instance as the one requiring map
  #

  def self.requires_map
    self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def requires_map?
        true
      end
    RUBY_EVAL
  end

  module MapHelpers

    def requires_map?
      false # by default
    end

  end

  include MapHelpers

  helper_method :requires_map?

end
