class User < ActiveRecord::Base

  def self.find_or_create_from_omniauth(auth)
    user = self.find_by(u_id: auth["uid"])
    if !user.nil?
      # User found in db
      return user
    else
      user = User.new
      user.u_id                   = auth["uid"]
      user.name                   = auth["info"]["name"]
      user.timezone               = auth["info"]["timezone"]
      user.stride_length_walking  = auth["extra"]["raw_info"]["user"]["strideLengthWalking"]
      user.stride_length_running  = auth["extra"]["raw_info"]["user"]["strideLengthRunning"]
      user.photo                  = auth["extra"]["raw_info"]["user"]["avatar"]
      user.save
      return user
    end
  end
end
