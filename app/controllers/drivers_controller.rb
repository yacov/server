class DriversController < ApplicationController

  before_filter :filter_driver, only: [:order, :accept, :cancel, :point, :status]

  def share
    u=User.where(ref: params[:ref]).first
    return render status: 404, text: "Reference user not found" if !u
    u.points+=1
    u.save
    return redirect_to 'https://play.google.com/store/apps/details?id=com.cooltaxi.users'
  end

  def register
    #error, if device_id not matches regular expression rule
    return render json: {errors: "Bad device id"}, status: 400 if params[:device_id] !~ /./

    # check whether there is a driver with the id or not
    dr=User.where(device_id: params[:device_id]).first
    return render json: {errors: "As the driver, you have already taken place"} if dr and dr.driver


    #this is line that makes you love ruby on rails, hope it's readable:
    # find user with device_id
    # if not found, create new object with device_id and ref set to md5(device_id:current_time)
    u = User.where(device_id: params[:device_id]).first_or_initialize(ref: Digest::MD5.hexdigest("#{params[:device_id]}:#{Time.now.to_f}"))
    u.phone= params[:phone]
    u.email= params[:email] if params[:email] =~ /.@.+\..+/ #TODO: stronger email validation
    u.save
    u.build_driver(:name=>params[:name],:car_id=>params[:car_id], :brand=>params[:brand]).save

                                #d=u.create_driver(name: params[:name],car_id: params[:car_id], brand: params[:brand])
                                #u.create_driver(name: params[:name],car_id: params[:car_id], brand: params[:brand])

    return render json: {id: u.id, ref: u.ref }
  end

  def point
    return render json: {id: @u.id, points: @u.points}
  end

  def order
    return render json: {errors: "Yu nat driver"} if !d=@u.driver
    gps_long_drivers = params[:gps_long_driver].to_f
    gps_lat_drivers = params[:gps_lat_driver].to_f
    result=Order.find_by_sql"SELECT *, ((ACOS(SIN(#{gps_lat_drivers} * PI() / 180) * SIN(`gps_lat_user` * PI() / 180) + COS(#{gps_lat_drivers} * PI() / 180) * COS(`gps_lat_user` * PI() / 180) * COS((#{gps_long_drivers} - `gps_long_user`) * PI() / 180)) * 180 / PI()) * 60 * 1.1515) AS distance FROM orders WHERE status = #{Order::Status::OPEN} HAVING distance <= 3 ORDER BY distance LIMIT 10"
    return render :json => result.map{|result|{:id=> result.id, :user_id=> result.user_id, :dist=>result.distance.to_f, :address=> result.address }} if result                                                                                                                                                #* 6378245
    return render json: {error:"no orders"}

    #result = Order.find_by_sql" SELECT *, 2 * 6371* ASIN(SQRT(POW(SIN(((#{gps_lat_drivers}-gps_lat_user) / 2)*PI()/180), 2)+COS(#{gps_lat_drivers}*PI()/180) * COS(gps_lat_user*PI()/180) *POW(SIN(((#{gps_long_drivers}- gps_long_user) / 2)*PI()/180), 2)))  AS distance FROM orders WHERE status = #{Status::OPEN} HAVING distance <= 5 ORDER BY distance LIMIT 10"
    #result = Order.find_by_sql" SELECT *, 2 * 3956* ASIN(SQRT(POW(SIN((#{gps_lat_drivers}-gps_lat_user)*PI()/180 / 2), 2)+COS(#{gps_lat_drivers}*PI()/180) * COS(gps_lat_user*PI()/180) *POW(SIN((#{gps_long_drivers}- gps_long_user)*PI()/180 / 2), 2)))  AS distance FROM orders WHERE status = #{Status::OPEN} HAVING distance <= 5 ORDER BY distance LIMIT 10"

  end

  def status
      return render json: {errors: "Order with this id does not exist"} if !o=@u.driver.orders.find_by_id(params[:order_id])
      return render json: {errors: "Order this id is closed"} if o.status==Order::Status::CLOSED
      return render json: {errors: "Order this id closed user "} if o.status==Order::Status::UsersClosed
      return render json: {errors: "Order this you closed"} if o.status==Order::Status::DriversClosed
      o.update_attributes(gps_long_drivers: params[:gps_long_drivers],gps_lat_drivers: params[:gps_lat_drivers])
      return render json: {mesage: " 1 "}
  end

  def accept
    #return render json: {error: "order is already taken"} if @u.driver.orders.where(status: Order::Status::SELECT).first
    o=Order.where(:id => params[:order_id]).first
    return render json: {error: "Orders busy"} if (o.status==Order::Status::SELECT)      # -check- -> #  else return render json: {text: "order tut"}
    d=@u.driver
    d.orders<<o
    o.update_attributes(gps_long_drivers: params[:gps_long_drivers],gps_lat_drivers: params[:gps_lat_drivers], status: Order::Status::SELECT)
    @u.points=@u.points-1
    return render json: {message:"Your order"}
  end

  def cancel
    return render json: {errors: "Yu nat driver"} if !d=@u.driver
    o=d.orders.where(id: params[:order_id],status: Order::Status::SELECT).first
    o.status=Order::Status::DriversClosed
    o.save
    @u.points=@u.points-1
    u.save
    return render json: {message: "Taken you order transferred to the free mode"}
  end

  def took
    o=@u.driver.orders.find_by_id(params[:order_id])
    o.status=Order::Status::CLOSED if o.status==Order::Status::DriversTook
    o.status=Order::Status::UsersVillages if o.status== Order::Status::SELECT
    return render json: {mesage: 'Thank you for using our application'}
  end


  private
  def filter_driver
    return render json: {error: "This id does not exist in the database"} if !(@u=User.find_by_id(params[:driver_id]))
  end
end


