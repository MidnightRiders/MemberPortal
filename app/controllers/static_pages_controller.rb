class StaticPagesController < ApplicationController

  before_filter(only: :standings) { raise CanCan::AccessDenied.new('Cannot view standings.', :standings) unless user_signed_in? }

  def home
    redirect_to user_home_path if user_signed_in?
  end

  def faq
  end

  def contact
  end

  def games

  end

  def standings
    require 'will_paginate/array'
    @users = User.includes(:pick_ems,:rev_guesses).order('username ASC, last_name ASC, first_name ASC')
    @pick_em_standings = @users.select{|x| x.pick_em_score > 0 }.sort_by(&:pick_em_score).reverse.paginate(page: params[:pick_em_p], per_page: 25)
    @rev_guess_standings = @users.select{|x| x.rev_guesses.count > 0 }.sort_by(&:rev_guess_score).reverse.paginate(page: params[:rev_guess_p], per_page: 25)
  end
end
