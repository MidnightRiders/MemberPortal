class StylesheetsController < ApplicationController
  def club
    @clubs = Club.all
    respond_to do |format|
      format.css { render content_type: 'text/css' }
    end
  end
end
