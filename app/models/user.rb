class User < ActiveRecord::Base

  def self.find_or_create_from_omniauth(auth)
    user = self.find_by(u_id: auth["uid"])
    if !user.nil?
      # User found in db
      if user.user_token != auth['credentials']['token'] && user.user_secret != auth['credentials']['secret']
        user.user_token = auth['credentials']['token']
        user.user_secret = auth['credentials']['secret']
        user.refresh_token = auth["credentials"]["refresh_token"]
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
      user.refresh_token          = auth["credentials"]["refresh_token"]
      user.save
      return user
    end
  end

  def get_fitbit_client
    client = FitgemOauth2::Client.new({
      client_id: ENV['FITBIT_OAUTH2_CLIENT_ID'],
      client_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })

    refresh_data = client.refresh_access_token(self.refresh_token)
    self.user_token = refresh_data["access_token"]
    self.refresh_token = refresh_data["refresh_token"]

    client = FitgemOauth2::Client.new({
      client_id: ENV['FITBIT_OAUTH2_CLIENT_ID'],
      client_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })

    return client
  end

  def refresh_access_token
    # Refresh Token
    encoded = Base64.strict_encode64("#{ENV['FITBIT_OAUTH2_CLIENT_ID']}:#{ENV['FITBIT_CLIENT_SECRET']}")
    auth = "Basic #{encoded}"
    content_type = "application/x-www-form-urlencoded"
    response = HTTParty.post("https://api.fitbit.com/oauth2/token", headers: {"Authorization" => auth, "Content-Type" => content_type}, body: {"grant_type" => "refresh_token", "refresh_token" => self.refresh_token})
    # raise
    if response["access_token"].nil?
      raise
    else
      self.user_token = response["access_token"]
      self.refresh_token = response["refresh_token"]
    end
  end

  def get_current_steps
    # refresh_access_token
    # Get request
    today = Time.now.utc + (self.offset_from_utc_millis / 1000) # convert difference to seconds
    formatted_today = today.strftime('%Y-%m-%d')
    auth = "Bearer #{self.user_token}"
    response = HTTParty.get("https://api.fitbit.com/1/user/-/activities/date/#{formatted_today}.json", headers: { "Authorization" => auth })
    if response["errors"]
      refresh_access_token
      auth = "Bearer #{self.user_token}"
      response = HTTParty.get("https://api.fitbit.com/1/user/-/activities/date/#{formatted_today}.json", headers: { "Authorization" => auth })
    end
    current_steps = response["summary"]["steps"]
    return current_steps
  end

  def get_step_goal
    # refresh_access_token
    today = Time.now.utc + (self.offset_from_utc_millis / 1000) # convert difference to seconds
    formatted_today = today.strftime('%Y-%m-%d')
    auth = "Bearer #{self.user_token}"
    response = HTTParty.get("https://api.fitbit.com/1/user/-/activities/date/#{formatted_today}.json", headers: { "Authorization" => auth })

    if response["errors"]
      refresh_access_token
      auth = "Bearer #{self.user_token}"
      response = HTTParty.get("https://api.fitbit.com/1/user/-/activities/date/#{formatted_today}.json", headers: { "Authorization" => auth })
    end

    step_goal = response["goals"]["steps"]
    return step_goal
  end

  def get_steps_for_week
    # refresh_access_token
    week_data = []
    weekdays = []
    day = Time.now.utc + (self.offset_from_utc_millis / 1000)
    day_minus_seven = day - 518400 #milliseconds
    day_formatted = day.strftime("%Y-%m-%d")
    day_minus_seven_formatted = day_minus_seven.strftime("%Y-%m-%d")

    # data = client.activity_on_date_range("steps", day_minus_seven_formatted, day_formatted)

    auth = "Bearer #{self.user_token}"
    response = HTTParty.get("https://api.fitbit.com/1/user/-/activities/steps/date/#{day_minus_seven_formatted}/#{day_formatted}.json", headers: { "Authorization" => auth })

    if response["errors"]
      refresh_access_token
      auth = "Bearer #{self.user_token}"
      response = HTTParty.get("https://api.fitbit.com/1/user/-/activities/steps/date/#{day_minus_seven_formatted}/#{day_formatted}.json", headers: { "Authorization" => auth })
    end

    # Array of Hashes with keys corresponding to date and step values
    response["activities-steps"].each do |day|
      weekdays << Date.parse(day["dateTime"]).strftime("%A")
      week_data << day["value"].to_i
    end
    return week_data, weekdays
  end

  def get_badges
    # client = get_fitbit_client
    # data = client.badges

    auth = "Bearer #{self.user_token}"
    response = HTTParty.get("https://api.fitbit.com/1/user/-/badges.json", headers: { "Authorization" => auth })

    if response["errors"]
      refresh_access_token
      auth = "Bearer #{self.user_token}"
      response = HTTParty.get("https://api.fitbit.com/1/user/-/badges.json", headers: { "Authorization" => auth })
    end

    lifetime_distance_badge = nil
    # Sort through badges to find lifetime distance badge
    response["badges"].each do |badge|
      if badge["badgeType"] == "LIFETIME_DISTANCE"
        lifetime_distance_badge = badge
        break
      end
    end
    name = lifetime_distance_badge["name"]
    value = lifetime_distance_badge["value"]
    badge_info = {name: name, value: value}
    return badge_info
  end

  def get_next_badge(current_badge)
    # All Fitbit Lifetime Distance Badges
    badges = [
      {:value => 26, :name => "Marathon (26 lifetime miles)"},
      {:value => 70, :name => "Penguin March (70 lifetime miles)"},
      {:value => 250, :name => "London Underground (250 lifetime miles)"},
      {:value => 350, :name => "Hawaii (350 lifetime miles)"},
      {:value => 500, :name => "Serengeti (500 lifetime miles)"},
      {:value => 736, :name => "Italy (736 lifetime miles)"},
      {:value => 990, :name => "New Zealand (990 lifetime miles)"},
      {:value => 1600, :name => "Great Barrier Reef (1600 lifetime miles)"},
      {:value => 1869, :name => "Japan (1869 lifetime miles)"},
      {:value => 1997, :name => "India (1997 lifetime miles)"},
      {:value => 2500, :name => "Monarch Migration (2500 lifetime miles)"},
      {:value => 2983, :name => "Sahara (2983 lifetime miles)"},
      {:value => 4132, :name => "Nile (4132 lifetime miles)"},
      {:value => 5000, :name => "Africa (5000 lifetime miles)"},
      {:value => 5500, :name => "Great Wall (5500 lifetime miles)"},
      {:value => 5772, :name => "Russian Railway (5772 lifetime miles)"},
      {:value => 7900, :name => "Earth (7900 lifetime miles)"},
      {:value => 12430, :name => "Pole to Pole (12430 lifetime miles)"}
    ]
    current_badge_value = current_badge[:value]
    next_badge = nil
    index = 0
    badges.each do |badge|
      if badge[:value] == current_badge_value
        next_badge = badges[index + 1]
        break
      end
      index += 1
    end
    return next_badge
  end

  def get_lifetime_distance()
    auth = "Bearer #{self.user_token}"
    response = HTTParty.get("https://api.fitbit.com/1/user/-/activities.json", headers: { "Authorization" => auth })

    if response["errors"]
      refresh_access_token
      auth = "Bearer #{self.user_token}"
      response = HTTParty.get("https://api.fitbit.com/1/user/-/activities.json", headers: { "Authorization" => auth })
    end

    total_distance = response["lifetime"]["total"]["distance"] # in km
    total_distance *= 0.621371
    return total_distance
  end

  def get_steps_to_next_badge(next_badge, lifetime_distance)
    distance_needed = next_badge[:value] - lifetime_distance # in miles
    distance_needed_cm = distance_needed * 160934
    steps_needed = (distance_needed_cm / self.stride_length_walking.to_f).round
    return steps_needed
  end
end
