class SiteController < ApplicationController
  def index
    if logged_in?
      @current_steps = current_user.get_current_steps
      @step_goal = current_user.get_step_goal
    end
  end
end
