# TODO: Flesh out Membership Controller for creation, modification, etc

# Controller for +Membership+ model.
class MembershipsController < ApplicationController
  before_action :get_membership, except: %i(new create webhooks)
  authorize_resource except: [:webhooks]
  before_action :get_user, except: [:webhooks]
  before_action :build_membership, only: [:create]
  before_action :admin_grant_membership, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:webhooks]

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
    ErrorNotifier.notify(e)
  end

  # GET /users/:user_id/memberships/new
  def new
    prepare_new_form
    @membership = @user.memberships.new(
      year: @year,
      privileges: @user.memberships.last.try(:privileges)
    )
  end

  # POST /users/:user_id/memberships
  # POST /users/:user_id/memberships.json
  def create
    @membership.save_with_payment!(params[:card_id])
    MembershipNotifier.new(user: @user, membership: @membership).notify_new

    redirect_to user_membership_path(@user, @membership), notice: t('.payment_successful')
  rescue => err
    flash.now[:error] = ErrorNotifier.notify(err)

    prepare_new_form
    render action: 'new'
  end

  # PATCH/PUT /users/:user_id/memberships/1/cancel
  # PATCH/PUT /users/:user_id/memberships/1/cancel.json
  def cancel
    respond_to do |format|
      refund = params.fetch(:refund, false).in? [true, 'true']
      if @membership.cancel(refund)
        if refund
          MembershipMailer.membership_cancellation_alert(@user, @membership).deliver_now
          MembershipMailer.membership_refund_email(@user, @membership).deliver_now
        end
        format.html { redirect_to get_user_path, notice: "Membership was successfully canceled#{" and #{'marked as' if @membership.override.present?} refunded" if refund}." }
        format.json { render json: { notice: "Membership was successfully canceled#{" and #{'marked as' if @membership.override.present?} refunded" if refund}." }, status: :ok }
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
    webhook = StripeWebhookService.new(params)
    render webhook.process
  end

  private

  def admin_grant_membership
    return if @user == current_user
    if @membership.save
      redirect_to get_user_path, notice: 'Membership was successfully created.'
    else
      redirect_to new_user_membership_path(@user), flash: { error: @membership.errors.full_messages.to_sentence }
    end
  end

  # Define +@user+ based on route +:user_id+
  def get_user
    @user = User.find_by(username: params[:user_id])
  end

  # Define +@membership+ based on route +:id+
  def get_membership
    @membership = Membership.unscoped.find(params[:id] || params[:membership_id])
  end

  def build_membership
    @membership = @user.memberships.new(membership_params)
  end

  # Determine where to redirect after success
  def get_user_path
    @user == current_user ? user_home_path : user_path(@user)
  end

  def prepare_new_form
    @year = Date.current.month > 10 ? Date.current.year + 1 : Date.current.year
    @cards = @user.stripe_customer.cards.data if @user.stripe_customer.present?
  end

  # Strong params for +Membership+
  def membership_params
    params.require(:membership).permit(:user_id, :year, :type, :stripe_card_token, :subscribe, privileges: []).tap do |whitelisted|
      whitelisted[:info] = params[:membership][:info]
    end
  end
end
