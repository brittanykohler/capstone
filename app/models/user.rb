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

  def get_steps_for_week
    client = Fitgem::Client.new({
      consumer_key: ENV['FITBIT_CLIENT_ID'],
      consumer_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })

    # Reconnects existing user using the information above
    client.reconnect(self.user_token, self.user_secret)

    week_data = []
    weekdays = []
    day = Time.now.utc + (self.offset_from_utc_millis / 1000)
    7.times do
      weekdays << day.strftime("%a")
      day_formatted = day.strftime("%Y-%m-%d")
      data = client.activities_on_date(day_formatted)
      week_data << data["summary"]["steps"]
      day -= 86400
    end
    week_data.reverse!
    weekdays.reverse!
    return week_data, weekdays
  end

  def get_badges
    client = Fitgem::Client.new({
      consumer_key: ENV['FITBIT_CLIENT_ID'],
      consumer_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })

    # Reconnects existing user using the information above
    client.reconnect(self.user_token, self.user_secret)
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
    client = Fitgem::Client.new({
      consumer_key: ENV['FITBIT_CLIENT_ID'],
      consumer_secret: ENV['FITBIT_CLIENT_SECRET'],
      token: self.user_token,
      secret: self.user_secret,
      user_id: self.u_id,
    })

    # Reconnects existing user using the information above
    client.reconnect(self.user_token, self.user_secret)
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
