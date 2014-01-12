class CreateUsersAndDrivers < ActiveRecord::Migration
  def up
    create_table   :users do |t|                       #id is automatic
      t.string     :device_id, null: false
      t.string     :phone
      t.string     :email
      t.integer    :points, null: false, default: 0
      t.string     :ref
      t.timestamps                                     #creates created_on and updated_on
    end
    add_index :users, :device_id, unique: true         #searching by device_id on registration
    add_index :users, :ref, unique: true               #searching by ref on sharing
    
    #in document i wrote also "status" but it's unused in API, so I'm not adding it here yet

    create_table   :drivers,id: false do |t|
      t.integer    :user_id
      t.string     :name
      t.string     :car_id
      t.string     :brand
      t.timestamps                                      #creates created_on and updated_on
    end
    add_index :drivers, :user_id                        #primary key of the table


    create_table :orders do |t|
      t.integer  :user_id                               #field to link the client to the table
      t.string   :address                               #address of the client is determined at the time of booking
      t.float    :gps_long_user,    :limit=> 30         #longitude coordinates of the client
      t.float    :gps_lat_user,     :limit=> 30         #client coordinates latitude
      t.integer  :driver_id                             #field to link the driver to the table
      t.float    :gps_long_drivers, :limit=> 30         #longitude coordinates of the drivers
      t.float    :gps_lat_drivers,  :limit=> 30         #driver coordinates latitude
                                                        #t.string   :good_luck                             #field successfully completed order
                                                        #t.string   :cancellations                         #rusal to Order
      t.integer  :status                                #determining the status of an order
    end
    add_index :orders, :user_id
    add_index :orders, :driver_id
    add_index :orders, :status
  end

  def down
    drop_table :orders
    drop_table :drivers
    drop_table :users
  end
end
