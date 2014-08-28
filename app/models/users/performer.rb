
module Users

  extend Common::ForceConventionalNaming

  class Performer < User

    has_many  :orders,
              :class_name  => "Travels::Travel",
              :inverse_of  => :performer

    #
    # This is binding for GCM (or alike) subscription
    #

    has_one   :subscription,
              :class_name => "Communication::Push::Subscription",
              :dependent  => :destroy,
              :as         => :subscriber,

              # NOTE:
              #   Sad enough to say, that polymorphic associations are incompatible
              #   with `inverse_of` (see ActiveRecord::Associations `inverse_of`)
              #
              #   And lack of `inverse_of` could cause unexpected side-effects:
              #
              #    d = Dungeon.first
              #    t = d.traps.first
              #    d.level == t.dungeon.level # => true
              #    d.level = 10
              #    d.level == t.dungeon.level # => false
              #
              #   See Bi-directional associations

              :inverse_of => :performer


    #
    # API interface is (so far) accommodating only performers
    # needs, however this will be revisited shortly
    #

    has_one   :token,
              :class_name => "Api::Token",
              :as         => :owner,

              # NOTE:
              #   Sad enough to say, that polymorphic associations are incompatible
              #   with `inverse_of` (see ActiveRecord::Associations `inverse_of`)
              #
              #   And lack of `inverse_of` could cause unexpected side-effects:
              #
              #    d = Dungeon.first
              #    t = d.traps.first
              #    d.level == t.dungeon.level # => true
              #    d.level = 10
              #    d.level == t.dungeon.level # => false
              #
              #   See Bi-directional associations

              :inverse_of => :owner


  end

end