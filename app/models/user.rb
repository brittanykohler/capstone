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

  def get_fitbit_client
    client = FitgemOauth2::Client.new({
      client_id: ENV['FITBIT_CLIENT_ID'],
      client_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })
    raise
    # Reconnects existing user using the information above
    # client.reconnect(self.user_token, self.user_secret)
    return client
  end

  def get_current_steps
    client = get_fitbit_client
    # client.activities_on_date('2015-03-25') <- Specific Date
    today = Time.now.utc + (self.offset_from_utc_millis / 1000) # convert difference to seconds
    formatted_today = today.strftime('%Y-%m-%d')
    info = client.activities_on_date(formatted_today)
    current_steps = info["summary"]["steps"]
    return current_steps
  end

  def get_step_goal
    client = get_fitbit_client
    # client.activities_on_date('2015-03-25') <- Specific Date
    info = client.activities_on_date('today')
    step_goal = info["goals"]["steps"]
    return step_goal
  end

  def get_steps_for_week
    client = get_fitbit_client

    week_data = []
    weekdays = []
    day = Time.now.utc + (self.offset_from_utc_millis / 1000)
    day_minus_seven = day - 518400 #milliseconds
    day_formatted = day.strftime("%Y-%m-%d")
    day_minus_seven_formatted = day_minus_seven.strftime("%Y-%m-%d")

    data = client.activity_on_date_range("steps", day_minus_seven_formatted, day_formatted)

    # Array of Hashes with keys corresponding to date and step values
    data["activities-steps"].each do |day|
      weekdays << Date.parse(day["dateTime"]).strftime("%A")
      week_data << day["value"].to_i
    end
    return week_data, weekdays
  end

  def get_badges
    client = get_fitbit_client
    data = client.badges
    lifetime_distance_badge = nil
    # Sort through badges to find lifetime distance badge
    data["badges"].each do |badge|
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
    client = get_fitbit_client
    data = client.activity_statistics
    total_distance = data["lifetime"]["total"]["distance"]
    return total_distance
  end

  def get_steps_to_next_badge(next_badge, lifetime_distance)
    distance_needed = next_badge[:value] - lifetime_distance # in miles
    distance_needed_cm = distance_needed * 160934
    steps_needed = (distance_needed_cm / self.stride_length_walking.to_f).round
    return steps_needed
  end
end
