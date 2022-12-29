# Controller for static pages – home, faq, contact. Only visible
class StaticPagesController < ApplicationController

  authorize_resource class: false, only: %i[standings transactions nominate]

  # Root path. Shows sign_in if not signed in, user_home if signed in
  def home
    redirect_to user_signed_in? ? user_home_path : new_user_session_path
  end

  # Frequently Asked Questions
  def faq
  end

  # TODO: Fill out Contact

  # Basic contact information
  def contact
  end

  # Shows standings for Pick 'Em and RevGuess.
  def standings
    @season = params.fetch(:season, Date.current.year)
    @rev_guess_standings = User.rev_guess_scores(@season).where('(SELECT COUNT(*) FROM rev_guesses LEFT JOIN matches ON rev_guesses.match_id = matches.id WHERE rev_guesses.user_id = users.id AND EXTRACT(YEAR FROM matches.kickoff)=? AND rev_guesses.score IS NOT NULL) > 0', @season).order('rev_guesses_score DESC, rev_guesses_count ASC, username ASC').paginate(page: params[:rev_guess_p], per_page: 25)
    @pick_em_standings = User.pick_em_scores(@season).where('(SELECT COUNT(*) FROM pick_ems LEFT JOIN matches ON pick_ems.match_id = matches.id WHERE pick_ems.user_id = users.id AND EXTRACT(YEAR FROM matches.kickoff)=? AND pick_ems.correct IS NOT NULL) > 0', @season).order('correct_pick_ems DESC, total_pick_ems ASC, username ASC').paginate(page: params[:pick_em_p], per_page: 25)
  end

  # Nominate board member
  def nominate
    nomination = params[:nomination]&.permit(:name, :position)&.to_h
    UserMailer.new_board_nomination_email(current_user, nomination).deliver_now
    redirect_to user_home_path, notice: 'Thank you for your nomination.'
  rescue ArgumentError => e
    redirect_to user_home_path, flash: { alert: e.message }
  end

  # Admin-only: view transactions
  def transactions
    view = 'memberships'
    case params[:view]
    when 'detailed'
      require 'will_paginate/array'
      @transactions = stripe_events
      tokens = @transactions.map { |e| e.data.object.object == 'customer' ? e.data.object.id : e.data.object.try(:customer) }.reject(&:nil?)
      @users = User.where(stripe_customer_token: tokens).map { |u| [u.stripe_customer_token, u] }.to_h
      view = 'transactions'
    when 'all'
      @transactions = Membership.unscoped.includes(:user).where.not(type: 'Relative').order(created_at: :desc).paginate(per_page: 25, page: params[:page])
    when 'refunded'
      @transactions = Membership.refunds.includes(:user).where.not(type: 'Relative').reorder(created_at: :desc).paginate(per_page: 25, page: params[:page])
    else
      @transactions = Membership.includes(:user).where.not(type: 'Relative').reorder(created_at: :desc).paginate(per_page: 25, page: params[:page])
    end

    respond_to do |format|
      format.html { render view }
      format.js { render json: @transactions }
    end
  end

  def preact
    render 'preact', layout: false
  end

  private

  def stripe_events
    events = Stripe::Event.all(limit: 25, starting_after: params[:starting_after])
    @has_more = events.has_more
    events.data
  end
end
