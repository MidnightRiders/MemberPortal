class UsersController < ApplicationController
  load_and_authorize_resource find_by: :username

  # GET /users
  # GET /users.json
  def index
    @role = params[:role] || nil
    @users = @users.text_search(params[:search])
    if @role
      @users = @users.where(roles: { name: @role }).order('last_name ASC, first_name ASC').paginate(page: params[:p], per_page: 20)
    else
      @users = @users.order('last_name ASC, first_name ASC').paginate(page: params[:p], per_page: 20)
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /home
  def home
    @articles = RidersBlog.articles.sort_by{|x| x['pubDate'].to_date }.last(2).reverse
    @events = FacebookApi.events['data'].try(:select){|x| x['start_time'] >= Time.current - 1.week }
    @matches = Match.where('kickoff >= ? AND kickoff <= ?', Date.current.beginning_of_week, Date.current.beginning_of_week + 7.days).order('kickoff ASC').select{|x| !x.teams.include? revs }
    @revs_matches = revs.previous_matches + revs.next_matches(2)
  end

  def edit
    if current_user == @user && cannot?(:manage, User)
      redirect_to edit_user_registration_path(@user)
    end
    @membership = @user.current_membership
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        flash.now[:success] = 'Thank you for updating your information!'
        format.html { redirect_to @user }
        format.json { render json: { json: flash, html: render_to_string(partial: 'layouts/notifications', formats: [:html], locals: { flash: flash }) } }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @user = User.new
    @membership = @user.memberships.new(year: Date.current.year)
  end

  def create

    u = user_params
    u[:password] = (pass = rand(36**10).to_s(36))

    @user = User.new(u)

    respond_to do |format|
      if @user.save
        UserMailer.new_user_creation_email(@user,pass)
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    if params[:file]
      User.import(params[:file])
      redirect_to users_path, notice: 'Users imported.'
    else
      redirect_to users_path, alert: 'No file was selected'
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username, { role_ids: [] })
    end
end
