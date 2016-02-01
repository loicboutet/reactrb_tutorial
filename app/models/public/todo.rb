class Todo < ActiveRecord::Base

  scope :complete, -> () {where(:complete => true)}
  scope :active, -> () {where.not(:complete => true)}

end
