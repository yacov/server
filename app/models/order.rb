class Order < ActiveRecord::Base

  belongs_to :user
  belongs_to :driver#, :foreign_key => "driver_id"

private
  class Status
    OPEN          = 1
    SELECT        = 2
    CLOSED        = 3
    UsersClosed   = 4
    DriversClosed = 5
  end
end
