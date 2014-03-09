class StaticPagesController < ApplicationController
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
    @users = User.includes(:pick_ems,:rev_guesses).order('username ASC, last_name ASC, first_name ASC')
    @pick_em_standings = @users.paginate(page: params[:pick_em_p], per_page: 25).sort_by(&:pick_em_score)
    @rev_guess_standings = @users.paginate(page: params[:rev_guess_p], per_page: 25).sort_by(&:rev_guess_score)
  end
end
