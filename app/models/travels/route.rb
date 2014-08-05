module Travels

  class Route < ActiveRecord::Base

    belongs_to  :travel,
                :class_name => Travel,
                :inverse_of => :route

  end

end