require 'rails_helper'

RSpec.describe SiteController, type: :controller do
  describe "GET #index" do
    context "logged in" do
      it "renders the index page" do
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
        user = double(User)
        allow(user).to receive(:offset_from_utc_millis).and_return(-28800000)
        allow(user).to receive(:get_current_steps).and_return(1890)
        allow(user).to receive(:get_step_goal).and_return(10000)
        allow(user).to receive(:stride_length_walking).and_return(72.4)
        allow(User).to receive(:find).and_return(user)
        session[:user_id] = 18978
        get :results
        expect(response).to render_template :results
      end
    end
  end

  describe "GET #stats" do
    context "logged in" do
      it "renders the stats page" do
        user = double(User)
        allow(user).to receive(:offset_from_utc_millis).and_return(-28800000)
        allow(user).to receive(:get_current_steps).and_return(1890)
        allow(user).to receive(:get_step_goal).and_return(10000)
        allow(user).to receive(:stride_length_walking).and_return(72.4)
        allow(user).to receive(:get_badges).and_return({name: "Marathon (26 lifetime miles)", value: 26})
        allow(user).to receive(:get_next_badge).and_return({:value => 70, :name => "Penguin March (70 lifetime miles)"})
        allow(user).to receive(:get_lifetime_distance).and_return(50)
        allow(user).to receive(:get_steps_to_next_badge).and_return(5890)
        allow(user).to receive(:get_steps_for_week).and_return([123, 4, 5, 6, 7, 6, 7], ["M", "T", "W", "Th", "F", "S", "S"])
        allow(User).to receive(:find).and_return(user)
        session[:user_id] = 18978
        get :stats
        expect(response).to render_template :stats
      end
    end
  end

  describe "GET #trips" do
    context "logged in" do
      it "renders the trips page" do
        user = double(User)
        allow(user).to receive(:get_current_steps).and_return(1890)
        allow(user).to receive(:get_step_goal).and_return(10000)
        allow(user).to receive(:stride_length_walking).and_return(72.4)
        allow(User).to receive(:find).and_return(user)
        session[:user_id] = 18978
        get :trips
        expect(response).to render_template :trips
      end
    end
  end
end
