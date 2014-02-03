require 'common/force_conventional_naming'

module Users

  class Customer < User

    include Common::ForceConventionalNaming

    has_many :orders,
             :class_name  => Travel,
             :inverse_of  => :customer

  end

end