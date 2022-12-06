# Controller for +User+ model.
class UsersController < ApplicationController
  load_and_authorize_resource find_by: :username

  # GET /users
  # GET /users.json
  def index
    @params = params.permit(:privilege, :search, :show_all, :year)
    @privilege = @params[:privilege].blank? ? nil : @params[:privilege]
    @year = @params.fetch(:year, Date.current.year).to_i
    @show_all = @params[:show_all].in? [true, 'true']
    @user_set = @users
    @user_set = @user_set.text_search(@params[:search]) if @params[:search]
    @user_set = @user_set.where(memberships: { year: @year }) unless @show_all
    @user_set = @user_set.where('memberships.privileges::jsonb ?| array[:privileges]', year: Date.current.year, privileges: [@privilege].flatten) if @privilege
    @user_set = @user_set.includes(:memberships).order(last_name: :asc, first_name: :asc)
    @users = @user_set.paginate(page: @params[:p], per_page: 20)

    respond_to do |format|
      format.html
      format.json
      format.csv {
        render text: @user_set.to_csv(year: @year)
      }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /home
  def home
    @articles = RidersBlog.articles.sort_by { |x| x['pubDate'].to_date }.last(2).reverse if RidersBlog.articles
    @events = FacebookApi.events['data'].try(:select) { |x| x['start_time'] >= Time.current - 1.week } if FacebookApi.events
    @revs_matches = [revs.last_match, revs.next_matches(2)].flatten.reject(&:nil?)
  end

  # GET /users/1/edit
  def edit
    unless current_user.privilege?('admin') || current_user.privilege?('executive_board')
      redirect_to edit_user_registration_path(@user)
    end
    @membership = @user.current_membership
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        flash.now[:success] = 'Thank you for updating your information!'
        format.html { redirect_to @user }
        format.json { render json: { json: flash, flash: render_to_string(partial: 'layouts/notifications', formats: [:html], locals: { flash: flash }) } }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/new
  def new
    @user = User.new
    @membership = @user.memberships.new(year: Date.current.year)
  end

  # POST /users
  # POST /users.json
  def create
    u = user_params
    u[:password] = (pass = rand(36**10).to_s(36))

    @user = User.new(u)

    respond_to do |format|
      if @user.save
        UserMailer.new_user_creation_email(@user, pass)
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /users/import
  # Accepts +:file+ to import new +Users+.
  def import
    authorize! :import, :users

    raise 'No file was selected' unless params[:file]
    file = CSV.read(params[:file].path.to_s, headers: true, header_converters: :symbol).map(&:to_h)
    users = User.import(file, override_id: current_user.id)
    redirect_to users_path, notice: "#{users.size} #{'user'.pluralize(users.size)} imported."
  rescue CanCan::AccessDenied => e
    redirect_to root_path, e.message
  rescue => e
    Rails.logger.warn e.message
    Rails.logger.info e.backtrace.to_yaml
    redirect_to users_path, alert: e.message
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :country, :phone, :email, :member_since, :username)
  end
end
