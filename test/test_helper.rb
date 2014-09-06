ENV["RAILS_ENV"] ||= "test"

require File.expand_path('../../config/environment', __FILE__)

require 'application_helper'
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  set_fixture_class(
    travels:  "Travels::Travel",
    states:   "Travels::State",
    places:   "Travels::Places::Place",

    items:    "Item",

    users:    "Users::User",
    roles:    "Users::Roles::Role"
  )

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  # fixtures "users/users", "travels/places/places", "travels/travels", "items"

end
