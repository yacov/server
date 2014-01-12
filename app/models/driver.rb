class Driver < ActiveRecord::Base
  self.primary_key = :user_id   #rails loves when primary key called "id", not always that's the case
  belongs_to :user              #will auto-use User model and user_id column
  has_many :orders              #- for future, that's how orders will be associated'
end