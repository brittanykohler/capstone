class SiteController < ApplicationController
  def index
    @current_steps = current_user.get_current_steps
    @step_goal = current_user.get_step_goal
  end
end
