# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  last_name              :string(255)
#  first_name             :string(255)
#  address                :string(255)
#  city                   :string(255)
#  state                  :string(255)
#  postal_code            :string(255)
#  phone                  :integer
#  email                  :string(255)      default(""), not null
#  username               :string(255)      default(""), not null
#  member_since           :integer
#  created_at             :datetime
#  updated_at             :datetime
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  stripe_customer_token  :string(255)
#  country                :string(255)
#

class User < ActiveRecord::Base
  IMPORTABLE_ATTRIBUTES = %w(last_name first_name last_name address city state postal_code phone email member_since username).freeze
  CSV_ATTRIBUTES = %w(id last_name first_name address city state postal_code phone email username member_since last_sign_in_at country).freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  delegate :can?, :cannot?, to: :ability

  default_scope { includes(:memberships) }

  # Get all current members, or members for specified year
  scope :members, lambda { |year = (Date.current.year..Date.current.year + 1)|
    where(memberships: { year: year })
  }

  # Get non-members
  scope :non_members, lambda { |year = (Date.current.year..Date.current.year + 1)|
    where.not(id: joins(:memberships).members(year).select('id'))
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :memberships

  has_many :mot_ms
  has_many :rev_guesses
  has_many :pick_ems

  validates :first_name, :last_name, :email, presence: true
  validates :username, presence: true, uniqueness: true, case_sensitive: false
  validates :username, format: { with: /\A[\w\-]{5,}\z/i }
  validates :member_since, numericality: { less_than_or_equal_to: Date.current.year, greater_than_or_equal_to: 1995, only_integer: true }, allow_blank: true

  has_paper_trail only: %i(username email first_name last_name address city state postal_code phone member_since)

  # Returns +privileges+ from current +Membership+
  def current_privileges
    current_membership.try(:privileges) || []
  end

  # Returns *Boolean*. Determines whether the user has a given privilege.
  def privilege?(r)
    current_privileges.include? r
  end

  # Returns *String*. Lists all privileges, comma-separated or in plain english if +verbose+ is true.
  def list_current_privileges(verbose = false, no_admin = false)
    ps = current_privileges.map(&:titleize)
    ps = ps.reject { |v| v == 'admin' } if no_admin
    if ps.empty?
      'None'
    elsif verbose
      ps.to_sentence
    else
      ps.join(', ')
    end
  end

  # A test that comes up a lost
  def leadership_or_admin?
    privilege?('admin') || privilege?('executive_board')
  end

  # Returns +Membership+ for current year.
  def current_membership
    memberships.where(year: (Date.current.year..Date.current.year + 1)).order(year: :asc).first
  end

  # Returns +Family+ +Membership+ for current year, if applicable
  def current_family
    current_membership.try(:family)
  end

  # Returns *Boolean*. Determines whether user has a current membership.
  def current_member?
    current_membership.present?
  end

  # Returns +Relative+ +Membership+ if invited to join +Family+
  def family_invitation
    Membership.with_invited_email(email).first
  end

  # Returns *Boolean* based on +family_invitation+
  def invited_to_family?
    !current_member? && family_invitation.present?
  end

  # Returns +PickEm+ for given +match+, or new +PickEm+.
  def pick_for(match)
    pick_ems.find_by(match: match) || PickEm.new
  end

  # Returns *String*. Either picked result, or +nil+.
  def pick_result(match)
    pick_for(match).try(:result)
  end

  # Returns *String*. URL for Gravatar based on email.
  def gravatar
    'https://gravatar.com/avatar/' + Digest::MD5.hexdigest(email.downcase.sub(/\+.+@/, '@')) + '?d=mm'
  end

  # Generates tedsmith1-style usernames to prevent conflicts
  def generate_username!
    return unless new_record?
    original_uname = self.username = "#{first_name}#{last_name}".downcase.gsub(/[^a-z]/, '')
    i = 0
    until User.find_by(username: username).nil?
      i += 1
      self.username = "#{original_uname}#{i}"
    end
  end

  def generate_temporary_password!
    return unless new_record?
    self.password = rand(36**10).to_s(36)
  end

  # Grants a +Membership+ for the current year. Part of import.
  def grant_membership!(type: 'Individual', privileges: [], granted_by: nil, family_id: nil)
    membership = memberships.where(year: Time.current.year).first_or_initialize
    membership.override ||= granted_by
    membership.privileges = privileges
    membership.type ||= type.titleize
    membership.family_id ||= family_id if type == 'Relative'
    membership.save!
    self
  end

  # Converts the phone to *Integer* for storage.
  def phone=(value)
    value.gsub!(/\D/, '') if value.is_a? String
    super(value)
  end

  # Used in generating readable URLs.
  def to_param
    username
  end

  # Quick semi-full-text search for Users.
  def self.text_search(query)
    if query.present?
      where 'username ilike :q or first_name ilike :q or last_name ilike :q or email ilike :q', q: "%#{query}%"
    else
      all
    end
  end

  # Retrieve Stripe customer object
  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_token) if stripe_customer_token
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe::InvalidRequestError: #{e}"
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def self.import(users, privileges: [], override_id: nil)
    imported_users = []
    family_id = nil

    users.each do |user_info|
      begin
        type = user_info[:membership_type]
        raise 'No Family for Relative' if family_id.nil? && type == 'Relative'
        user = from_hash(user_info).grant_membership!(type: type, privileges: privileges, granted_by: override_id, family_id: family_id)
        family_id = user.current_membership.id if type == 'Family'
        family_id = nil if type == 'Individual'
        imported_users << user
      rescue => e
        Rails.logger.warn e.message
        Rails.logger.info e.backtrace.join("\n")
      end
    end

    imported_users
  end

  # Import single user from hash
  def self.from_hash(user_hash)
    user_hash = user_hash.with_indifferent_access
    user = User.where(email: user_hash[:email]&.strip&.downcase).first_or_initialize

    user.assign_attributes(user_hash.select { |x| IMPORTABLE_ATTRIBUTES.include? x })
    user.generate_username!
    pass = user.generate_temporary_password!

    user.save!
    UserMailer.new_user_creation_email(user, pass).deliver_now if pass
    user
  end

  def self.pick_em_scores(season = Date.current.year)
    unscoped.select('*',
      sanitize_sql_array(['(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct AND matches.season = %s) AS correct_pick_ems', season]),
      sanitize_sql_array(['(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL AND matches.season = %s) AS total_pick_ems', season]))
  end

  def self.rev_guess_scores(season = Date.current.year)
    unscoped.select('*',
      sanitize_sql_array(['(SELECT SUM(rev_guesses.score) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = %s) AS rev_guesses_score', season]),
      sanitize_sql_array(['(SELECT COUNT(rev_guesses.id) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = %s) AS rev_guesses_count', season]))
  end

  def self.scores(season = Date.current.year)
    unscoped.select('*',
      sanitize_sql_array(['(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct AND matches.season = %s) AS correct_pick_ems', season]),
      sanitize_sql_array(['(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL AND matches.season = %s) AS total_pick_ems', season]),
      sanitize_sql_array(['(SELECT SUM(rev_guesses.score) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = %s) AS rev_guesses_score', season]),
      sanitize_sql_array(['(SELECT COUNT(rev_guesses.id) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = %s) AS rev_guesses_count', season]))
  end

  # Outputs CSV
  def self.to_csv
    CSV.generate do |csv|
      csv << (CSV_ATTRIBUTES + %w(current_member membership_type)).map(&:titleize)
      all.find_each do |user|
        csv << user.attributes.values_at(*CSV_ATTRIBUTES) + [user.current_membership.present?, user.current_membership.try(:type)]
      end
    end
  end
end
