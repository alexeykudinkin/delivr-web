class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  module SessionHelpers
    module ClassMethods
      #
      # Fence actions that require user to be logged in prior
      # to executing them
      #

      def _fenced_actions
        @_fenced_actions ||= []
      end

      #
      # Registers filter to query session state
      # whether user is logged in or not
      #

      def require_login(*actions)
        # FIXME
        _fenced_actions.concat [ *actions ]

        prepend_before_action only: _fenced_actions do |controller|
          demand_login(controller)
        end
      end
    end

    def demand_login(controller)
      unless controller.send(:logged_in?)
          redirect_to login_path, alert: "You must be logged in!"
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end

  module LocaleHelpers
    module ClassMethods
      def localize
        before_action :set_request_locale
      end
    end

    def set_request_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end

  include SessionHelpers
  include LocaleHelpers


  #
  # Localization
  #

  localize


  #
  # Helpers
  #

  module UserHelpers

    def current_user
      @_current_user ||= Users::User.find_by(id: session[:user]) if session[:user]
    end

    def logged_in?
      !current_user.blank?
    end

    def admin?
      logged_in? && (current_user.role == Users::Roles::Role.as("Admin"))
    end

  end

  include UserHelpers

  helper_method :current_user, :logged_in?


  module MapHelpers
    module ClassMethods
      #
      # Marks controller instance as the one requiring map
      #
      def requires_map
        self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def requires_map?
            true
          end
        RUBY_EVAL
      end
    end

    def requires_map?
      false # by default
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end

  include MapHelpers

  helper_method :requires_map?


  module CoordinatesHelpers
    def update_location(location)
      Coordinates.find_or_create_by(user_id: current_user.id) do |loc|
        loc.latitude = location[:latitude]
        loc.longitude = location[:longitude]
      end
    end

    def drop_location
      Coordinates.find(user_id: current_user.id).destroy
    end
  end

  include CoordinatesHelpers

end
