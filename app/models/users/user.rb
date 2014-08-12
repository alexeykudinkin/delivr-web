module Users

  extend Common::ForceConventionalNaming

  class User < ActiveRecord::Base

    # Enable basic authentication
    has_secure_password

    # Role management
    belongs_to :role,
               :class_name => Users::Roles::Role,
               :inverse_of => :accounts

    has_one :coordinates

    # Validations

    validates :name,  :presence => true
    validates :phone, :presence => true
    validates :email, :presence => true

    validates :role,  :presence => true

    validates_associated :role

  end

end
