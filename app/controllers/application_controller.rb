class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :current_user

  helper_method :current_user
  helper_method :logged_in?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end


  # might use later for authentication purposes
  # def require_user
  #   if !logged_in?
  #     flash[:error] = "Please log in to view this section"
  #     redirect_to root_path
  #   end
  # end

  def logged_in?
    !current_user.nil?
  end
end
