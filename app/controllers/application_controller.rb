class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session


  module ControllerHelpers

    def fail(format, status, message)
      respond_to do |_format|
        _format.send(format) { render status: status, text: message }
      end
    end

  end

  include ControllerHelpers


  module SessionHelpers
    extend ActiveSupport::Concern

    module ClassMethods
      # Registers filter to query session state
      # whether user is logged in or not
      def restrict_access(*actions)
        # FIXME
        (@_fenced_actions ||= []).concat [ *actions ]

        send :prepend_before_action, only: @_fenced_actions do |controller|
          force_authenticate(controller)
        end
      end
    end

    def force_authenticate(controller)
      unless controller.send(:authenticated?)
        respond_to do |format|
          format.html { redirect_to login_path, alert: "You must be logged in!" }
          format.json { render json: { message: "You should be authenticated to have access to the API!" }, status: 401 }
        end
      end
    end
  end


  module LocaleHelpers
    extend ActiveSupport::Concern

    module ClassMethods
      def localize
        before_action :set_request_locale
      end
    end

    def set_request_locale
      I18n.locale = params[:locale] || I18n.default_locale
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
      @_current_user ||= begin
        (Users::User.find_by(id: session[:user]) if session[:user]) || authenticate_with_http_token do |token, _|
          token = Api::Token.find_by(value: token)
          unless token.blank?
            token.owner
          end
        end
      end
    end

    def authenticated?
      !current_user.blank?
    end

    def admin?
      authenticated? && (current_user.role == Users::Roles::Role.as("Admin"))
    end

  end

  include UserHelpers

  helper_method :current_user, :authenticated?


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
