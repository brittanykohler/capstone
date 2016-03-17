require 'rails_helper'

RSpec.describe SiteController, type: :controller do
  describe "GET #index" do
    context "logged in" do
      it "renders the index page" do
        user = User.create(u_id: ENV["FITBIT_UID"], name: "Brittany", timezone: "LosAngeles",
          offset_from_utc_millis: -28800000, stride_length_walking: 72.4,
          stride_length_running: 85, photo: "www.google.com",
          user_token: ENV["FITBIT_USER_TOKEN"], user_secret: ENV["FITBIT_USER_SECRET"])
        session[:user_id] = user.id
        get :index
        expect(response).to render_template :index
      end

      it "does things" do
        # move to user spec
        # client = double(Fitgem::Client)
        # allow(client).to receive(:reconnect)
        # allow(client).to receive(:activities_on_date).and_return({"summary" => {"steps" => "4"}, "goals" => {"steps" => "10000"}})
        #
        # allow_any_instance_of(User).to receive(:get_fitbit_client).and_return(client)

        user = double(User)
        allow(user).to receive(:offset_from_utc_millis).and_return(-28800000)
        allow(user).to receive(:get_current_steps).and_return(1890)
        allow(user).to receive(:get_step_goal).and_return(10000)
        allow(User).to receive(:find).and_return(user)
        session[:user_id] = 18978
        get :index
        expect(response).to render_template :index
      end
    end
  end

  describe "GET #results" do
    context "logged in" do
      it "renders the results page" do
        user = User.create(u_id: ENV["FITBIT_UID"], name: "Brittany", timezone: "LosAngeles",
          offset_from_utc_millis: -28800000, stride_length_walking: 72.4,
          stride_length_running: 85, photo: "www.google.com",
          user_token: ENV["FITBIT_USER_TOKEN"], user_secret: ENV["FITBIT_USER_SECRET"])
        session[:user_id] = user.id
        get :results
        expect(response).to render_template :results
      end
    end
  end

  describe "GET #stats" do
    context "logged in" do
      it "renders the stats page" do
        user = User.create(u_id: ENV["FITBIT_UID"], name: "Brittany", timezone: "LosAngeles",
          offset_from_utc_millis: -28800000, stride_length_walking: 72.4,
          stride_length_running: 85, photo: "www.google.com",
          user_token: ENV["FITBIT_USER_TOKEN"], user_secret: ENV["FITBIT_USER_SECRET"])
        session[:user_id] = user.id
        get :stats
        expect(response).to render_template :stats
      end
    end
  end

  describe "GET #trips" do
    context "logged in" do
      it "renders the trips page" do
        user = User.create(u_id: ENV["FITBIT_UID"], name: "Brittany", timezone: "LosAngeles",
          offset_from_utc_millis: -28800000, stride_length_walking: 72.4,
          stride_length_running: 85, photo: "www.google.com",
          user_token: ENV["FITBIT_USER_TOKEN"], user_secret: ENV["FITBIT_USER_SECRET"])
        session[:user_id] = user.id
        get :trips
        expect(response).to render_template :trips
      end
    end
  end
end
