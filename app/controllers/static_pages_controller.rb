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
    @pick_em_standings = User.includes(:pick_ems).where.not(pick_ems: { correct: nil }).sort_by{|u| u.pick_ems.score }.reverse.paginate(page: params[:pick_em_p], per_page: 25)
    @rev_guess_standings = User.includes(:rev_guesses).where.not(rev_guesses: { score: nil }).sort_by{|u| u.rev_guesses.score }.reverse.paginate(page: params[:rev_guess_p], per_page: 25)
  end
end
