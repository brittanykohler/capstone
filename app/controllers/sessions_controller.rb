class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    @user = User.find_or_create_from_omniauth(auth_hash)
    session[:user_id] = @user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
