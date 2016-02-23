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
  # describe "get_current_steps" do
  #   before :each do
  #     @auth_hash = OmniAuth::AuthHash.new({:uid => '123545',
  #       info: {name: "Brittany", timezone: "LosAngeles"},
  #       extra: {raw_info: {user: {strideLengthWalking: "72", strideLengthRunning: "95", avatar: "www.google.com"}}},
  #       credentials: {token: 'cea7f5c7bc9ea044db48185e7d5cab03', secret: '4ceeac658fc959bb96ed29f9f9e67fa7'}})
  #   end
  #
  #   it "returns a step value" do
  #     user = User.find_or_create_from_omniauth(@auth_hash)
  #     steps = user.get_current_steps
  #     expect(steps).not_to be_nil
  #   end
  # end
end
