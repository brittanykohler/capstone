class User < ActiveRecord::Base

  def self.find_or_create_from_omniauth(auth)
    user = self.find_by(u_id: auth["uid"])
    if !user.nil?
      # User found in db
      if user.user_token != auth['credentials']['token'] && user.user_secret != auth['credentials']['secret']
        user.user_token = auth['credentials']['token']
        user.user_secret = auth['credentials']['secret']
        user.save
      end
      return user
    else
      # create new user in db
      user = User.new
      user.u_id                   = auth["uid"]
      user.name                   = auth["info"]["name"]
      user.timezone               = auth["info"]["timezone"]
      user.offset_from_utc_millis = auth["extra"]["raw_info"]["user"]["offsetFromUTCMillis"]
      user.stride_length_walking  = auth["extra"]["raw_info"]["user"]["strideLengthWalking"]
      user.stride_length_running  = auth["extra"]["raw_info"]["user"]["strideLengthRunning"]
      user.photo                  = auth["extra"]["raw_info"]["user"]["avatar"]
      user.user_token             = auth["credentials"]["token"]
      user.user_secret            = auth["credentials"]["secret"]
      user.save
      return user
    end
  end

  def get_current_steps
    client = Fitgem::Client.new({
      consumer_key: ENV['FITBIT_CLIENT_ID'],
      consumer_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })

    # Reconnects existing user using the information above
    client.reconnect(self.user_token, self.user_secret)

    # client.activities_on_date('2015-03-25') <- Specific Date
    today = Time.now.utc + (self.offset_from_utc_millis / 1000) # convert difference to seconds
    formatted_today = today.strftime('%Y-%m-%d')
    info = client.activities_on_date(formatted_today)
    current_steps = info["summary"]["steps"]
    return current_steps
  end

  def get_step_goal
    client = Fitgem::Client.new({
      consumer_key: ENV['FITBIT_CLIENT_ID'],
      consumer_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })

    # Reconnects existing user using the information above
    client.reconnect(self.user_token, self.user_secret)

    # client.activities_on_date('2015-03-25') <- Specific Date
    info = client.activities_on_date('today')
    step_goal = info["goals"]["steps"]
    return step_goal
  end
end
