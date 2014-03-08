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
end
