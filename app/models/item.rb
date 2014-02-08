class Item < ActiveRecord::Base

  belongs_to :travel,
             :class_name => Travels::Travel,
             :inverse_of => :items

end
