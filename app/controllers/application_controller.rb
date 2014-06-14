class ApplicationController < ActionController::Base
  #protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, :with => :render_missing
  def reports_all
    result=User.find_by_sql"SELECT id, email,points FROM users"
    return render :json => result.map{|result|{status:"OK", :id_driver=> result.id,:email=>result.email,:points=>result.points}} if result.any?
  end
  private

  def render_missing
    return render json: {errors: "Error while searching ID"}
     render 'This is a 404', :status => 404
  end
  def render_404
    render file: "public/404.html",status: 404 ,layout: false
  end
  def filter_timeout
    Order.connection.execute('UPDATE orders SET orders.status = 8, orders.time_close=UTC_TIMESTAMP() WHERE orders.status = 1 AND (TIMESTAMPDIFF(MINUTE,orders.time_start,UTC_TIMESTAMP)>10)')
  end
end

