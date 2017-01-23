class MembershipDecorator < Draper::Decorator
  delegate_all

  # Returns *String*. Lists all privileges, comma-separated or in plain english if +verbose+ is true.
  def list_privileges(verbose = false, no_admin = false)
    ps = privileges.map(&:titleize)
    ps = ps.reject { |v| v == 'admin' } if no_admin
    if privileges.empty?
      'None'
    elsif verbose
      ps.to_sentence
    else
      ps.join(', ')
    end
  end
end
