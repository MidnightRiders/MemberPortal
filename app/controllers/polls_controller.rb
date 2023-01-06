# frozen_string_literal: true

class PollsController < ApplicationController
  load_and_authorize_resource

  def index
    @polls.order!(start_time: :desc, end_time: :desc)
  end

  def show; end

  def new
    @poll.start_time ||= Time.now.beginning_of_hour + 1.hour
    @poll.end_time ||= Time.now.beginning_of_hour + 1.hour + 2.weeks
  end

  def create
    if @poll.save
      redirect_to @poll
    else
      render :new
    end
  end

  def edit; end

  def update
    if @poll.update(poll_params)
      redirect_to @poll
    else
      render :edit
    end
  end

  def destroy
    @poll.destroy
    redirect_to polls_path
  end

  private

  def poll_params
    params.require(:poll).permit(
      :title, :description, :start_time, :end_time, :multiple_choice,
      poll_options_attributes: %i[id title image _destroy]
    )
  end
end
