# TODO: Flesh out Membership Controller for creation, modification, etc

# Controller for +Membership+ model.
class MembershipsController < ApplicationController
  load_and_authorize_resource except: [ :webhooks ]
  before_action :get_user, except: [ :webhooks ]
  skip_before_action :verify_authenticity_token, only: [ :webhooks ]

  # GET /users/:user_id/memberships
  # GET /users/:user_id/memberships.json
  def in
    @memberships = @user.memberships
  end

  # GET /users/:user_id/memberships/1
  # GET /users/:user_id/memberships/1.json
  def show
  end

  # GET /users/:user_id/memberships/new
  def new
    privileges = @user.memberships.last.try(:privileges)
    year = Date.current.month > 10 ? Date.current.year + 1 : Date.current.year
    @membership = @user.memberships.new(year: year, privileges: privileges)
  end

  # GET /users/:user_id/memberships/1/edit
  def edit
  end

  # POST /users/:user_id/memberships
  # POST /users/:user_id/memberships.json
  def create
    # binding.pry
    @membership = @user.memberships.new(membership_params)

    respond_to do |format|
      if @membership.save_with_payment
        format.html { redirect_to get_user_path, notice: 'Membership was successfully created.' }
        format.json { render action: 'show', status: :created, location: @membership }
      else
        format.html { render action: 'new' }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/:user_id/memberships/1
  # PATCH/PUT /users/:user_id/memberships/1.json
  def update
    respond_to do |format|
      if @membership.update(membership_params)
        format.html { redirect_to get_user_path, notice: 'Membership was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/:user_id/memberships/1/refund
  # PATCH/PUT /users/:user_id/memberships/1/refund.json
  def refund
    respond_to do |format|
      if @membership.refund
        format.html { redirect_to get_user_path, notice: "Membership was successfully #{@membership.decorate.refund_action(true)}." }
        format.json { render json: { notice: "Membership was successfully #{@membership.decorate.refund_action(true)}."}, status: :ok }
      else
        binding.pry
        format.html { redirect_to get_user_path }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/:user_id/memberships/1
  # DELETE /users/:user_id/memberships/1.json
  def destroy
    @membership.destroy
    respond_to do |format|
      format.html { redirect_to @user }
      format.json { head :no_content }
    end
  end

  # ALL /memberships/webhooks
  def webhooks
    event = Stripe::Event.retrieve(params[:id])
    object = event.data.object
    user  = User.find_by(stripe_customer_token: object.customer )
    if user
      if object.object == 'charge'
        membership = Membership.with_stripe_charge_id(object.id)
        if event.type == 'charge.succeeded'
          logger.error "Membership for Stripe::Charge #{object.id} already exists." if membership
          user.memberships.create!(
            year: object.metadata[:year] || Date.current.year,
            type: object.metadata[:type] || 'individual',
            info: { stripe_charge_id: object.id }
          )
        elsif event.type == 'charge.refunded'
          membership.refunded = true
          membership.save!
        end
      elsif object.object == 'invoice'
        if event.type = 'invoice.payment_successful'

        end
      end
    else
      logger.error "No user could be found with ID #{object.customer}\n  Event ID: #{event.id}"
    end
  rescue Stripe::StripeError => e
    logger.error "StripeError encountered: #{e}"
  end

  private

    # Define +@user+ based on route +:user_id+
    def get_user
      @user = User.find_by(username: params[:user_id])
    end

    # Determine where to redirect after success
    def get_user_path
      @user == current_user ? user_home_path : user_path(@user)
    end

    # Strong params for +Membership+
    def membership_params
      params.require(:membership).permit(:user_id, :year, :type, :stripe_card_token, :subscription, privileges: []).tap do |whitelisted|
        whitelisted[:info] = params[:membership][:info]
      end
    end
end
