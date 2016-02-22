Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, ENV['FITBIT_CLIENT_ID'], ENV['FITBIT_CLIENT_SECRET']
end
