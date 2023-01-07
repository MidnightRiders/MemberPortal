# frozen_string_literal: true

class PollsController < ApplicationController
  load_and_authorize_resource

  def index
    @polls.order!(start_time: :desc, end_time: :desc)
  end

  def show; end

  def new
    @poll.multiple_choice ||= 1
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

  def vote
    authorize! :vote, @poll
    votes = params.require(:poll_option_id)
    votes = [votes] unless votes.is_a?(Array)
    raise ActionController::BadRequest, 'too many votes' if @poll.multiple_choice&.then { votes.size > _1 }
    ActiveRecord::Base.transaction do
      current_user.votes_for_poll(@poll).destroy_all
      current_user.poll_votes.create!(votes.map { |id| { poll_option_id: id } })
    end
    redirect_to user_home_path, flash: { notice: "Your #{'vote'.pluralize(votes.size)} #{votes.size == 1 ? 'has' : 'have'} been cast" }
  rescue ActiveRecord::ActiveRecordError => e
    redirect_to user_home_path, flash: { alert: e.message }
  rescue ActionController::ParameterMissing => e
    redirect_to user_home_path, flash: { alert: 'You must select at least one option' }
  rescue => e
    redirect_to user_home_path, flash: { alert: "Error: #{e.message}" }
  end

  private

  def poll_params
    params.require(:poll).permit(
      :title, :description, :start_time, :end_time, :multiple_choice,
      poll_options_attributes: %i[id title image _destroy]
    )
  end
end
