module Users

  extend Common::ForceConventionalNaming

  class User < ActiveRecord::Base

    # Enable basic authentication
    has_secure_password

    #
    # User role
    #

    belongs_to  :role,
                :class_name => Users::Roles::Role,
                :inverse_of => :accounts


    #
    # User state
    #

    include Users::State::ExportMethods

    has_one     :state,
                :class_name => Users::State,
                :dependent  => :destroy,
                :inverse_of => :user


    scope :active, -> { joins(:state).where(State.table_name => { status: :active }) }


    # Coordinates?

    has_one :coordinates

    # Validations

    validates :name,  :presence => true
    validates :phone, :presence => true
    validates :email, :presence => true

    validates :role,  :presence => true

    validates_associated :role

  end

end
