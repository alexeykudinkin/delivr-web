module Travels

  class DueDate < ActiveRecord::Base

    belongs_to :destination,
               :class_name => Places::Destination,
               :inverse_of => :due_date

  end

end