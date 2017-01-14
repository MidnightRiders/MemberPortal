# Controller for static pages – home, faq, contact. Only visible
class StaticPagesController < ApplicationController

  authorize_resource class: false, only: %i(standings transactions)

  # Root path. Shows sign_in if not signed in, user_home if signed in
  def home
    redirect_to user_signed_in? ? user_home_path : new_user_session_path
  end

  # Frequently Asked Questions
  def faq; end

  # TODO: Fill out Contact

  # Basic contact information
  def contact; end

  # Shows standings for Pick 'Em and RevGuess.
  def standings
    @season = params.fetch(:season, Date.current.year)
    @rev_guess_standings = User.rev_guess_scores(@season).where('(SELECT COUNT(*) FROM rev_guesses LEFT JOIN matches ON rev_guesses.match_id = matches.id WHERE rev_guesses.user_id = users.id AND EXTRACT(YEAR FROM matches.kickoff)=? AND rev_guesses.score IS NOT NULL) > 0', @season).order('rev_guesses_score DESC, rev_guesses_count ASC, username ASC').paginate(page: params[:rev_guess_p], per_page: 25)
    @pick_em_standings = User.pick_em_scores(@season).where('(SELECT COUNT(*) FROM pick_ems LEFT JOIN matches ON pick_ems.match_id = matches.id WHERE pick_ems.user_id = users.id AND EXTRACT(YEAR FROM matches.kickoff)=? AND pick_ems.correct IS NOT NULL) > 0', @season).order('correct_pick_ems DESC, total_pick_ems ASC, username ASC').paginate(page: params[:pick_em_p], per_page: 25)
  end

  # Admin-only: view transactions
  def transactions
    view = 'memberships'
    case params[:view]
    when 'detailed'
      require 'will_paginate/array'
      @transactions = stripe_events.paginate(per_page: 25, page: params[:page])
      @users = Hash[User.where(stripe_customer_token: @transactions.map { |e| e.data.object.object == 'customer' ? e.data.object.id : e.data.object.customer }.reject(&:nil?)).map { |u| [u.stripe_customer_token, u] }]
      view = 'transactions'
    when 'all'
      @transactions = Membership.unscoped.includes(:user).where.not(type: 'Relative').order(created_at: :desc).paginate(per_page: 25, page: params[:page])
    when 'refunded'
      @transactions = Membership.refunds.includes(:user).where.not(type: 'Relative').reorder(created_at: :desc).paginate(per_page: 25, page: params[:page])
    else
      @transactions = Membership.includes(:user).where.not(type: 'Relative').reorder(created_at: :desc).paginate(per_page: 25, page: params[:page])
    end

    respond_to do |format|
      format.html do render view end
      format.js { render json: @transactions }
    end
  end

  private

  def stripe_events
    if params[:refresh] || @stripe_events.nil?
      @stripe_events = []
      100.times do
        capture = Stripe::Event.all(limit: 100, starting_after: @stripe_events.last.try(:id))
        @stripe_events += capture.data
        break unless capture.has_more
      end
    end
    @stripe_events
  end
end
