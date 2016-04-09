class EmailsController < ApplicationController
  before_action :get_email, only: [:show, :edit, :update, :destroy]

  def index
    @emails = Email.all
  end

  def show
    layout 'email-template'
  end

  def new
    @email = Email.new
  end

  def create
    @email = Email.new(email_params)

    respond_to do |format|
      if @email.save
        format.html { redirect_to edit_email_path(@email), notice: 'Email was successfully created.' }
        format.json { render action: 'show', status: :created, location: @email }
      else
        format.html { render action: 'new' }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @email.update(email_params)
        format.html { redirect_to edit_email_path(@email), notice: 'Email was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @email.destroy
    respond_to do |format|
      format.html { redirect_to emails_url }
      format.json { head :no_content }
    end
  end

  private

  def get_email
    @email = Email.find(params[:id])
  end

  def email_params
    params.require(:email).permit(
      :title, :preheader, :content, :featured_shop,
      game: [
        :opponent,
        :location,
        :kickoff
      ],
      viewings: [
        :banshee,
        :parlor,
        :rumbleseat,
        :bison_county,
        british_beer: [
          :danvers,
          :framingham,
          :walpole
        ]
      ])
  end
end
