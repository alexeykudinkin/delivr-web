class Travel < ActiveRecord::Base

  has_many    :items,
              :class_name   => Item,
              :inverse_of   => :travel,
              :autosave     => true

  accepts_nested_attributes_for :items,
                                :reject_if => lambda { |item| item[:weight].blank?      ||
                                                              item[:name].blank?        &&
                                                              item[:description].blank?  }

  belongs_to  :customer,
              :class_name => Users::Customer,
              :inverse_of => :orders

  belongs_to  :performer,
              :class_name => Users::Performer,
              :inverse_of => :orders

end

