require 'common/force_conventional_naming'

module Users

  extend Common::ForceConventionalNaming

  class Customer < User

    has_many :orders,
             :class_name  => Travels::Travel,
             :inverse_of  => :customer

  end

end