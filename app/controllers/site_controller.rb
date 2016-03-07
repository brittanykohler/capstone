class SiteController < ApplicationController
  def index
    if logged_in?
      @current_steps = current_user.get_current_steps
      @step_goal = current_user.get_step_goal
      if @step_goal > @current_steps
        @steps_needed = @step_goal - @current_steps
      else # daily step goal is completed
        @steps_needed = 1250 # update this later
      end
      # distance is in meters
      @distance_needed = @steps_needed * current_user.stride_length_walking.to_f / 100
      gon.distance_needed = @distance_needed
      gon.stride_length_walking = current_user.stride_length_walking
    end
  end

  def results
    if logged_in?
      @current_steps = current_user.get_current_steps
      @step_goal = current_user.get_step_goal
      if @step_goal > @current_steps
        @steps_needed = @step_goal - @current_steps
      else # daily step goal is completed
        @steps_needed = 1250 # update this later
      end
      # distance in meters
      @distance_needed = @steps_needed * current_user.stride_length_walking.to_f / 100
      gon.distance_needed = @distance_needed
      gon.stride_length_walking = current_user.stride_length_walking
      gon.place_type = params[:format]
    end
  end

  def stats
    if logged_in?
      @current_steps = current_user.get_current_steps
      @step_goal = current_user.get_step_goal
      if @step_goal > @current_steps
        @steps_needed = @step_goal - @current_steps
      else # daily step goal is completed
        @steps_needed = 1250 # update this later
      end
      # distance is in meters
      @distance_needed = @steps_needed * current_user.stride_length_walking.to_f / 100
      gon.distance_needed = @distance_needed
      gon.stride_length_walking = current_user.stride_length_walking

      # for highchart data
      @chart_data, @chart_days = current_user.get_steps_for_week
      gon.chart_data = @chart_data
      gon.chart_days = @chart_days
      gon.step_goal = @step_goal
    end
  end

  def trips
    if logged_in?
      @current_steps = current_user.get_current_steps
      @step_goal = current_user.get_step_goal
      if @step_goal > @current_steps
        @steps_needed = @step_goal - @current_steps
      else # daily step goal is completed
        @steps_needed = 1250 # update this later
      end
      # distance is in meters
      @distance_needed = @steps_needed * current_user.stride_length_walking.to_f / 100
      gon.distance_needed = @distance_needed
      gon.stride_length_walking = current_user.stride_length_walking
    end
  end
end
