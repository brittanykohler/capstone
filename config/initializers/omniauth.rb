Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, ENV['FITBIT_OAUTH2_CLIENT_ID'], ENV['FITBIT_CLIENT_SECRET'], { :scope => 'profile activity', :redirect_uri => 'http://fittrip.herokuapp.com/auth/fitbit/callback' }
end
