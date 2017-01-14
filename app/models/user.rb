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
  IMPORTABLE_ATTRIBUTES = %i(last_name first_name last_name address city state postal_code phone email member_since username).freeze
  CSV_ATTRIBUTES = %w(id last_name first_name address city state postal_code phone email username member_since last_sign_in_at country).freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  delegate :can?, :cannot?, to: :ability

  default_scope { includes(:memberships) }

  scope :scores, ->(season = Date.current.year) {
    unscoped.select('*',
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct AND matches.season = #{season}) AS correct_pick_ems",
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL AND matches.season = #{season}) AS total_pick_ems",
      "(SELECT SUM(rev_guesses.score) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_score",
      "(SELECT COUNT(rev_guesses.id) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_count")
  }

  scope :rev_guess_scores, ->(season = Date.current.year) {
    unscoped.select('*',
      "(SELECT SUM(rev_guesses.score) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_score",
      "(SELECT COUNT(rev_guesses.id) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_count")
  }

  scope :pick_em_scores, ->(season = Date.current.year) {
    unscoped.select('*',
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct AND matches.season = #{season}) AS correct_pick_ems",
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL AND matches.season = #{season}) AS total_pick_ems")
  }

  # Get all current members, or members for specified year
  scope :members, ->(year = (Date.today.year..Date.today.year + 1)) {
    where(memberships: { year: year })
  }

  # Get non-members
  scope :non_members, ->(year = (Date.today.year..Date.today.year + 1)) {
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
  validates :member_since, numericality: { less_than_or_equal_to: Date.today.year, greater_than_or_equal_to: 1995, only_integer: true }, allow_blank: true

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
    memberships.where(year: (Date.today.year..Date.today.year + 1)).order(year: :asc).first
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
  def has_family_invitation?
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
    original_uname = self.username = "#{first_name}#{last_name}".downcase.gsub(/[^a-z]/, '')
    i = 0
    until User.find_by(username: username).nil?
      i += 1
      self.username = "#{original_uname}#{i}"
    end
  end

  # Grants a +Membership+ for the current year. Part of import.
  def grant_membership(type, privileges, granted_by)
    return unless User.find(granted_by)&.leadership_or_admin?
    memberships.where(year: Time.current.year).first_or_initialize.tap do |m|
      m.info = { override: granted_by }
      m.privileges = privileges
      m.type = type.titleize || 'Individual'
    end.save!
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

  # User import script. Needs work.
  def self.import(users, privileges: [], override_id: nil)
    imported_users = []

    users.each do |import_user|
      begin
        imported_users << user_with_membership_from_hash(import_user, privileges: privileges, override_id: override_id)
      rescue => e
        Rails.logger.warn e.message
      end
    end

    imported_users
  end

  # Outputs CSV
  def self.to_csv
    CSV.generate do |csv|
      csv << (CSV_COLUMNS + %w(current_member membership_type)).map(&:titleize)
      all.find_each do |user|
        csv << user.attributes.values_at(*CSV_COLUMNS) + [user.current_membership.present?, user.current_membership.try(:type)]
      end
    end
  end

  def self.user_with_membership_from_hash(user_hash, privileges: [], override_id: nil)
    raise 'Not importing Relatives yet' if user_hash[:membership_type] == 'Relative' # TODO: Allow Relative input
    raise "No email for #{user_hash[:first_name]} #{user_hash[:last_name]}" if user_hash[:email].blank?

    user = User.where(email: user_hash[:email].strip.downcase).first_or_initialize
    user.assign_attributes(user_hash.select { |x| IMPORTABLE_ATTRIBUTES.include? x.to_sym })
    user.generate_username! if user.new_record?
    pass = false
    user.password = (pass = rand(36**10).to_s(36)) if user.new_record?
    user.save!
    user.grant_membership(user_hash[:membership_type], privileges, override_id)
    UserMailer.new_user_creation_email(user, pass).deliver_now if pass
    user
  end
end
