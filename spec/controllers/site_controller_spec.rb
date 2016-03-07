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
