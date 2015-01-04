# Controller for static pages – home, faq, contact. Only visible
class StaticPagesController < ApplicationController

  authorize_resource class: false, only: [:standings]

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
    @rev_guess_standings = User.rev_guess_scores.where('(SELECT COUNT(*) FROM rev_guesses WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL) > 0').order('rev_guesses_score DESC, rev_guesses_count ASC, username ASC').paginate(page: params[:rev_guess_p], per_page: 25)
    @pick_em_standings = User.pick_em_scores.where('(SELECT COUNT(*) FROM pick_ems WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL) > 0').order('correct_pick_ems DESC, total_pick_ems ASC, username ASC').paginate(page: params[:pick_em_p], per_page: 25)
  end
end
