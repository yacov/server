class User < ActiveRecord::Base
  has_one :driver       #  will auto-use Driver model and drivers.user_id, because of the name
  has_many :orders      #  for future, that's how orders will be associated
end