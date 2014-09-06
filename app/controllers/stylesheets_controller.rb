# Creates stylesheets based on information in the database.
class StylesheetsController < ApplicationController

  # Creates stylesheet based on +Club+ records.
  def club
    @clubs = Club.all
    respond_to do |format|
      format.css { render content_type: 'text/css' }
    end
  end
end
