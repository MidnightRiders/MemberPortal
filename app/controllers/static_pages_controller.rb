# Controller for static pages – home, faq, contact. Only visible
class StaticPagesController < ApplicationController

  before_filter(only: :standings) { raise CanCan::AccessDenied.new('Cannot view standings.', :standings) unless user_signed_in? }

  # Root path. Shows sign_in if not signed in, user_home if signed in
  def home
    redirect_to user_signed_in? ? user_home_path : new_user_session_path
  end

  # TODO: Fill out FAQ

  # Frequently Asked Questions
  def faq
  end

  # TODO: Fill out Contact

  # Basic contact information
  def contact
  end

  # Shows standings for Pick 'Em and RevGuess.
  def standings
    require 'will_paginate/array'
    @users = User.includes(:pick_ems,:rev_guesses).order('username ASC, last_name ASC, first_name ASC')
    @pick_em_standings = @users.where.not(pick_ems: { id: nil }).sort_by(&:pick_em_score).reverse.paginate(page: params[:pick_em_p], per_page: 25)
    @rev_guess_standings = @users.where.not(rev_guesses: { id: nil }).sort_by(&:rev_guess_score).reverse.paginate(page: params[:rev_guess_p], per_page: 25)
  end
end
