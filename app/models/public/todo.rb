class Todo < ActiveRecord::Base

  scope :complete, -> () {where(:complete => true)}
  to_sync(:complete) { complete }
  scope :active, -> () {where(:complete => nil)}
  to_sync(:active) { !complete }

end
