require 'rails_helper'

RSpec.describe User, type: :model do
  describe "self.find_or_create_from_omniauth" do
    before :each do
      @auth_hash = OmniAuth::AuthHash.new({:uid => '123545',
        info: {name: "Brittany", timezone: "LosAngeles"},
        extra: {raw_info: {user: {strideLengthWalking: "72", strideLengthRunning: "95", avatar: "www.google.com"}}},
        credentials: {token: 'abcdef', secret: 'so secret'}})
    end

    it "returns a user" do
      user = User.find_or_create_from_omniauth(@auth_hash)
      expect(user).to be_an_instance_of User
    end

    it "creates a user" do
      User.find_or_create_from_omniauth(@auth_hash)
      expect(User.all.length).to eq 1
    end

    it "doesn't create a new user if user already exists" do
      User.find_or_create_from_omniauth(@auth_hash)
      User.find_or_create_from_omniauth(@auth_hash)
      expect(User.all.length).to eq 1
    end
  end

  # need to fix... how to stub methods out?
  describe "get_current_steps" do
    before :each do
      @auth_hash = OmniAuth::AuthHash.new({:uid => ENV["FITBIT_UID"],
        info: {name: "Brittany", timezone: "LosAngeles"},
        extra: {raw_info: {user: {strideLengthWalking: "72", strideLengthRunning: "95", avatar: "www.google.com", offsetFromUTCMillis: -28800000}}},
        credentials: {token: ENV["FITBIT_USER_TOKEN"], secret: ENV["FITBIT_USER_SECRET"]}})
    end

    it "returns a step value" do
      client = double(Fitgem::Client)
      allow(client).to receive(:reconnect)
      allow(client).to receive(:activities_on_date).and_return({"summary" => {"steps" => "4"}, "goals" => {"steps" => "10000"}})
      allow_any_instance_of(User).to receive(:get_fitbit_client).and_return(client)

      user = User.find_or_create_from_omniauth(@auth_hash)
      steps = user.get_current_steps
      expect(steps).to eq("4")
    end
  end

  describe "get_step_goal" do
    before :each do
      @auth_hash = OmniAuth::AuthHash.new({:uid => ENV["FITBIT_UID"],
        info: {name: "Brittany", timezone: "LosAngeles"},
        extra: {raw_info: {user: {strideLengthWalking: "72", strideLengthRunning: "95", avatar: "www.google.com", offsetFromUTCMillis: -28800000}}},
        credentials: {token: ENV["FITBIT_USER_TOKEN"], secret: ENV["FITBIT_USER_SECRET"]}})
    end

    it "returns a goal value" do
      client = double(Fitgem::Client)
      allow(client).to receive(:reconnect)
      allow(client).to receive(:activities_on_date).and_return({"summary" => {"steps" => "4"}, "goals" => {"steps" => "10000"}})
      allow_any_instance_of(User).to receive(:get_fitbit_client).and_return(client)

      user = User.find_or_create_from_omniauth(@auth_hash)
      goal = user.get_step_goal
      expect(goal).to eq("10000")
    end
  end

  describe "get_steps_for_week" do
    before :each do
      @auth_hash = OmniAuth::AuthHash.new({:uid => ENV["FITBIT_UID"],
        info: {name: "Brittany", timezone: "LosAngeles"},
        extra: {raw_info: {user: {strideLengthWalking: "72", strideLengthRunning: "95", avatar: "www.google.com", offsetFromUTCMillis: -28800000}}},
        credentials: {token: ENV["FITBIT_USER_TOKEN"], secret: ENV["FITBIT_USER_SECRET"]}})
    end

    it "returns week data and associated weekdays" do
      client = double(Fitgem::Client)
      allow(client).to receive(:reconnect)
      allow(client).to receive(:activity_on_date_range).and_return({"activities-steps" => [{"dateTime" => "03-08-1989", "value" => 123}]})
      allow_any_instance_of(User).to receive(:get_fitbit_client).and_return(client)

      user = User.find_or_create_from_omniauth(@auth_hash)
      week_data, weekdays = user.get_steps_for_week
      expect(week_data).to eq([123])
      expect(weekdays).to eq(["Thursday"])
    end
  end
end
