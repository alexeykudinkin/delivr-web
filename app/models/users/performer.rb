require 'common/force_conventional_naming'

module Users

  extend Common::ForceConventionalNaming

  class Performer < User

    has_many  :orders,
              :class_name  => Travels::Travel,
              :inverse_of  => :performer

    #
    # This is binding for GCM (or alike) subscription
    #

    has_one   :subscription,
              :class_name => Communication::Push::Subscription,
              :inverse_of => :performer,
              :as         => :subscriber

  end

end