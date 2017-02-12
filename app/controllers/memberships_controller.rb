# TODO: Flesh out Membership Controller for creation, modification, etc

# Controller for +Membership+ model.
class MembershipsController < ApplicationController
  before_action :get_membership, except: %i(new create webhooks)
  authorize_resource except: [:webhooks]
  before_action :get_user, except: [:webhooks]
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
    logger.error "Stripe error retrieving charge: #{e.message}"
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
    @membership = @user.memberships.new(membership_params)
    admin_grant_membership and return unless @user == current_user

    @membership.save_with_payment!(params[:card_id])
    MembershipNotifier.new(user: @user, membership: @membership).notify_new

    redirect_to user_membership_path(@user, @membership), notice: t('.payment_successful')
  rescue => e
    prepare_new_form
    flash.now[:error] = e.message
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
    accepted_webhooks = %w(charge.refunded invoice.payment_succeeded)

    event = params
    object = event[:data][:object]
    logger.info event[:type]
    logger.info object.to_yaml
    customer_token = (object[:object] == 'customer' ? object[:id] : object[:customer])
    if customer_token
      unless accepted_webhooks.include? event[:type]
        logger.warn "Stripe::Event type #{event[:type]} not in accepted webhooks. Returning 200."
        render nothing: true, status: 200 and return
      end

      user = User.find_by(stripe_customer_token: customer_token)

      if user
        if object[:object] == 'charge'
          membership = Membership.find_by(stripe_charge_id: object[:id])
          # charge.succeeded is handled immediately - no webhook
          if membership.present?
            if event[:type] == 'charge.refunded'
              membership.update_attribute(:refunded, 'true')
            end
          else
            logger.error "No membership associated with Stripe Charge #{object[:id]}."
          end
        elsif object[:object] == 'invoice'
          if event[:type] == 'invoice.payment_succeeded'
            logger.info 'Creating new membership'
            subscription = user.stripe_customer.subscriptions.retrieve(object[:subscription])
            year = Time.at(subscription.current_period_start).year
            m = user.memberships.find_by(year: year)
            if m.present?
              logger.info "Duplicate #{year} membership for #{user.username} (#{m.stripe_subscription_id}/#{subscription.id})"
              render nothing: true, status: 200 and return
            end
            membership = user.memberships.new(
              year: year,
              type: subscription.plan.id.titleize,
              stripe_subscription_id: subscription.id,
              stripe_charge_id: object[:charge]
            )
            membership.save!
            MembershipNotifier.new(user: user, membership: membership).notify_renewal
          end
        end
        render nothing: true, status: 200
      else
        logger.error "No User could be found with Stripe ID #{customer_token}\n  Event ID: #{event[:id]}"
        render nothing: true, status: 404
      end
    else
      logger.error 'No Stripe::Customer attached to event.'
      render nothing: true, status: 200
    end
  rescue => err
    logger.fatal "Webhooks error encountered: #{err}"
    logger.debug err
    render nothing: true, status: 500
  end

  private

  def admin_grant_membership
    if @membership.save
      redirect_to get_user_path, notice: 'Membership was successfully created.'
    else
      redirect_to new_user_membership_path(@user), flash: { error: @membership.errors.messages.to_sentence }
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
