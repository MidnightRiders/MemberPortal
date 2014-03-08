class UsersController < ApplicationController
  load_and_authorize_resource find_by: :username

  # GET /users
  # GET /users.json
  def index
    @role = params[:role] || nil
    opts = @role ? { roles: { name: @role}} : {}
    @users = User.includes(:roles).where(opts).order('last_name ASC, first_name ASC').paginate(page: params[:p], per_page: 10)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /home
  def home
    @matches = Club.includes(:home_matches).all.map(&:next_match).reject{|x| x.nil? }.sort_by{|x| x.kickoff }
    @matches.reject!{|x| @matches.select{|y| y.id==x.id}.length > 1}
  end

  def edit

  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @user = User.new
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
