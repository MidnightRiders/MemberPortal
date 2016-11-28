class MembershipDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def refund_action(past = false, refund = true)
    ed = past ? 'ed' : ''
    return "cancel#{ed}" unless h.can?(:refund, model)
    if model.is_subscription?
      "cancel#{ed}#{" and refund#{ed}" if refund}"
    elsif model.stripe_charge_id
      "refund#{ed}"
    elsif model.override
      "cancel#{ed} and mark#{ed} as refunded"
    end
  end

  def refund_icon(refund = true)
    h.fa_icon('times-circle') + ' ' +
    if model.is_subscription? && refund
      h.fa_icon('credit-card') + ' ' + h.fa_icon('calendar')
    elsif model.is_subscription?
      h.fa_icon 'calendar'
    elsif model.stripe_charge_id
      h.fa_icon 'credit-card'
    elsif model.override
      h.fa_icon 'bolt'
    end
  end

end
