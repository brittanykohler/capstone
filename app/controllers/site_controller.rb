class SiteController < ApplicationController
  def index
    if logged_in?
      date = Time.now.utc + (current_user.offset_from_utc_millis/1000)
      @date = date.strftime("%A %B %d").upcase
      @current_steps = current_user.get_current_steps
      @step_goal = current_user.get_step_goal
      if @step_goal > @current_steps
        @steps_needed = @step_goal - @current_steps
        @steps_needed_message = "#{@steps_needed} STEPS TO GO!"
        @percentage_bar = @current_steps.to_f / @step_goal
      else # daily step goal is completed
        @steps_needed = 1000
        @steps_needed_message = "Way to step it up! You met your daily goal."
        @percentage_bar = 1
      end
    end
  end

  def results
    if logged_in?
      @current_steps = current_user.get_current_steps
      @step_goal = current_user.get_step_goal
      if @step_goal > @current_steps
        steps_needed = @step_goal - @current_steps
        @steps_needed_message = "#{steps_needed} STEPS TO GO!"
      else # daily step goal is completed
        @steps_needed_message = "STEP GOAL MET!"
      end
      # Using steps from form
      @distance_needed = params[:steps].to_i * current_user.stride_length_walking.to_f / 100 # converting from cm to m
      if params[:'trip-type'] == "Round-trip"
        @distance_needed /= 2
      end
      gon.distance_needed = @distance_needed
      gon.stride_length_walking = current_user.stride_length_walking
      gon.place_type = params[:'place-type']
      gon.trip_type =  params[:'trip-type']
      gon.steps_needed = params[:steps]
    end
  end

  def stats
    if logged_in?
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
        @steps_needed_message = "#{@steps_needed} STEPS TO GO!"
      else # daily step goal is completed
        @steps_needed = 1000
        @steps_needed_message = "STEP GOAL MET!"
      end
      # distance is in meters
      @distance_needed = @steps_needed * current_user.stride_length_walking.to_f / 100
      gon.distance_needed = @distance_needed
      gon.stride_length_walking = current_user.stride_length_walking
    end
  end

  # For SSL
  def letsencrypt
    render plain: ENV['LE_AUTH_RESPONSE']
  end
end
