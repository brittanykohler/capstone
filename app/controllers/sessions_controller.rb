class SessionsController < ApplicationController
  def create
    # # OAuth Access Credentials -- do I need these?
    # oauth_token = params[:oauth_token]
    # oauth_verifier = params[:oauth_verifier]

    # OAuth Fitbit Info
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
