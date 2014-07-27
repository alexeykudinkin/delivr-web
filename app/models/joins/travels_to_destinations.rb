module Joins

  class TravelsToDestinations < ActiveRecord::Base

    belongs_to  :travel,
                :class_name => Travels::Travel,
                :inverse_of => :_t2d,
                :autosave   => true

    belongs_to  :destination,
                :class_name => Travels::Places::Destination,
                :inverse_of => :_d2t,
                :autosave   => true


    # Items binding

    has_many  :items,
              :class_name => Item,
              :inverse_of => :_t2d,
              :autosave   => true

  end

end