require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  context "is successful" do
    before { request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:fitbit] }

    it "redirects to the home page" do
      get :create
      expect(response).to redirect_to root_path
    end

    it "creates a user" do
      expect { get :create }.to change(User, :count).by(1)
    end

    it "doesn't create a new user if user already exists" do
      User.create(u_id: "123545", name: "Brittany")
      expect { get :create }.to change(User, :count).by(0)
    end

    it "assigns the session[:user_id]" do
      get :create
      expect(session[:user_id]).to eq assigns(:user).id
    end

    it "logs out" do
      delete :destroy
      expect(session[:user_id]).to eq nil
    end
  end
end
