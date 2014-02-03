class Item < ActiveRecord::Base

  belongs_to :travel,
             :class_name => Travel,
             :inverse_of => :items

end
