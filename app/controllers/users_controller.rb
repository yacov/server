class UsersController < ApplicationController

  before_filter :filter_user, only: [:order, :status, :cancel, :point,:payment, :withdrawn, :status_stat]

  def share
    u = User.where(ref: params[:ref]).first
                                                     #return render status: 404, text: "Reference user not found" if !@u
    return render_404 unless u
    u.points += 1
    u.save
    return redirect_to 'https://play.google.com/store/apps/details?id=com.cooltaxi.users'
  end
  def register
    #error, if device_id not matches regular expression rule
    return render json: {errors: "Bad device id"}, status: 400 if params[:device_id] !~ /./
    return render json: {errors: ""} if User.find_by_device_id(params[:device_id])
    
    #this is line that makes you love ruby on rails, hope it's readable:
    # find user with device_id
    # if not found, create new object with device_id and ref set to md5(device_id:current_time)
    u = User.where(device_id: params[:device_id]).first_or_initialize(ref: Digest::MD5.hexdigest("#{params[:device_id]}:#{Time.now.to_f}"))
    u.email = params[:email] if params[:email] =~ /.@.+\..+/ #TODO: stronger email validation
    u.phone = params[:phone]
    u.save                 #will create new or update existing
    return render json: {id: u.id, ref: u.ref}
  end
  def order
    return render json: {errors: "Yu driver"} if d=@u.driver            # check that the order is not the driver draws
    return render json: {errors: "Your order is still open"} if @u.orders.find_by_status(Order::Status::OPEN) || @u.orders.find_by_status(Order::Status::SELECT)
    o=@u.orders.create(:address=>params[:address],:gps_long_user=>params[:gps_long_user],:gps_lat_user=>params[:gps_lat_user],:status=>Order::Status::OPEN)
    #@u.points=@u.points-1 if @u.points > 0
    @u.save
    return render json: {id_o: o.id, id_u: @u.id}
  end
  def status
    return render json: {errors: "Order with this id does not exist"} if !o=@u.orders.find_by_id(params[:order_id])
    return render json: {errors: "Order this id is not accepted"} if o.status==Order::Status::OPEN
    return render json: {errors: "Order this id is closed"} if o.status==Order::Status::CLOSED
    return render json: {errors: "Order this id closed driver "} if o.status==Order::Status::DriversClosed
    return render json: {errors: "Order this you closed"} if o.status==Order::Status::UsersClosed
    d=o.driver
    return render json: {name: d.name, gps_long_drivers: o.gps_long_drivers, gps_lat_drivers: o.gps_lat_drivers}
  end
  def cancel
     return render json: {error: "It id not open order"} if !o=@u.orders
     o.find_by_id(params[:order_id]).update_attribute(:status, Order::Status::UserCansel)
     return render json: {text: "Order closed"}
  end
  def point
    return render json: {id: @u.id, points: @u.points}
  end

  def payment
    return render json: {error: "your account is not enough money to pay for the order"} if @u.points.to_i<0 || @u.points.to_i<params[:points].to_i
    @u.points=@u.points.to_i - params[:points].to_i
    return render json: {error: "error in order"} if !o=@u.orders.where(status: Order::Status::SELECT).first
    user_driver=User.find_by_id(o.driver_id)
    user_driver.points=user_driver.points.to_i+params[:points].to_i
    @u.save
    user_driver.save
    return render json: {masage: "payment went"}
  end

  def withdrawn
    o=@u.orders.find_by_id(params[:order_id])
    o.status=Order::Status::CLOSED if o.status==Order::Status::DriversTook
    o.status=Order::Status::UsersVillages if o.status== Order::Status::SELECT
    return render json: {mesage: 'Thank you for using our application'}
  end

  def status_stat
        #@u=User.find(params[:user_id])
        #o=Order.find_by_user_id(u.device_id)
        #o.status =Status::OPEN
        #o.save
    return render json: {error: "no"} if params
    return render json: {massage: "ys"} if !params
  end
  private
  def filter_user
    return render json: {error: "This id does not exist in the database"} if !(@u=User.find_by_id(params[:user_id]))
  end

end
