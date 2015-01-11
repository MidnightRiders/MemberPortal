# TODO: Flesh out Membership Controller for creation, modification, etc

# Controller for +Membership+ model.
class MembershipsController < ApplicationController
  authorize_resource except: [ :webhooks ]
  before_action :get_membership, except: [ :new, :create, :webhooks ]
  before_action :get_user, except: [ :webhooks ]
  skip_before_action :verify_authenticity_token, only: [ :webhooks ]

  # GET /users/:user_id/memberships
  # GET /users/:user_id/memberships.json
  def index
    @memberships = @user.memberships
  end

  # GET /users/:user_id/memberships/1
  # GET /users/:user_id/memberships/1.json
  def show
    @card = nil
    if @membership.stripe_charge_id
      @card = Stripe::Charge.retrieve(@membership.stripe_charge_id).card
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe error retrieving charge: #{e.message}"
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
    @membership = @user.memberships.new(membership_params)

    respond_to do |format|
      if @membership.save_with_payment
        MembershipMailer.new_membership_confirmation_email(@user, @membership).deliver
        MembershipMailer.new_membership_alert(@user, @membership).deliver
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

  # PATCH/PUT /users/:user_id/memberships/1/cancel
  # PATCH/PUT /users/:user_id/memberships/1/cancel.json
  def cancel
    respond_to do |format|
      refund = params.fetch(:refund, false).in? [true, 'true']
      if @membership.cancel(refund)
        if refund
          MembershipMailer.membership_cancellation_alert(@user, @membership).deliver
          MembershipMailer.membership_refund_email(@user, @membership).deliver
        end
        format.html { redirect_to get_user_path, notice: "Membership was successfully canceled#{" and #{'marked as' if @membership.override.present?} refunded" if refund}." }
        format.json { render json: { notice: "Membership was successfully canceled#{" and #{'marked as' if @membership.override.present?} refunded" if refund}."}, status: :ok }
      else
        format.html { redirect_to get_user_path, alert: @membership.errors.messages.map(&:last).join('\n') }
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
    logger.info event.type
    logger.info event.data.object
    object = event.data.object
    user  = User.find_by(stripe_customer_token: object.object == 'customer' ? object.id : object.customer )
    if user
      customer = Stripe::Customer.retrieve(object.customer)
      if object.object == 'charge'
        membership = Membership.with_stripe_charge_id(object.id)
        # charge.succeeded is handled immediately - no webhook
        if event.type == 'charge.refunded'
          membership.refunded = true
          membership.save!
        end
      elsif object.object == 'invoice'
        subscription = customer.subscriptions.retrieve(object.subscription)
        if event.type == 'invoice.payment_succeeded'
          membership = user.memberships.new(
            year: Time.at(subscription.current_period_start),
            type: subscription.plan.id.titleize,
            info: {
              stripe_subscription_id: subscription.id
            }
          )
          MembershipMailer.membership_subscription_confirmation_email(@user, @membership).deliver if membership.save
        end
      else
        render status: 200
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

    # Define +@membership+ based on route +:id+
    def get_membership
      @membership = Membership.unscoped.find(params[:id])
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
