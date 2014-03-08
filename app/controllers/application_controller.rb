class ApplicationController < ActionController::Base
  #protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, :with => :render_missing

  private
  def render_missing
    return render json: {errors: "Error while searching ID"}
     render 'This is a 404', :status => 404
  end
  def render_404
    render file: "public/404.html",status: 404 ,layout: false
  end
end
