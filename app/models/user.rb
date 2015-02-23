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
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  default_scope { includes(:memberships) }

  scope :scores, ->(season = Date.current.year) {
    unscoped.select('*',
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct AND matches.season = #{season}) AS correct_pick_ems",
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL AND matches.season = #{season}) AS total_pick_ems",
      "(SELECT SUM(rev_guesses.score) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_score",
      "(SELECT COUNT(rev_guesses.id) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_count" )
  }

  scope :rev_guess_scores, ->(season = Date.current.year) {
    unscoped.select('*',
      "(SELECT SUM(rev_guesses.score) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_score",
      "(SELECT COUNT(rev_guesses.id) FROM rev_guesses LEFT JOIN matches ON matches.id = rev_guesses.match_id WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL AND matches.season = #{season}) AS rev_guesses_count" )
  }

  scope :pick_em_scores, ->(season = Date.current.year) {
    unscoped.select('*',
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct AND matches.season = #{season}) AS correct_pick_ems",
      "(SELECT COUNT(pick_ems.id) FROM pick_ems LEFT JOIN matches ON matches.id = pick_ems.match_id WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL AND matches.season = #{season}) AS total_pick_ems" )
  }

  # Get all current members, or members for specified year
  scope :members, ->(year = (Date.today.year..Date.today.year+1)) {
    where(memberships: { year: year })
  }

  # Get non-members
  scope :non_members, -> (year = (Date.today.year..Date.today.year+1)) {
    where.not(id: joins(:memberships).members(year).select('id'))
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :memberships

  has_many :mot_ms
  has_many :rev_guesses
  has_many :pick_ems

  validates :first_name, :last_name, presence: true
  validates :username, presence: true, uniqueness: true, case_sensitive: false
  validates :username, format: { with: /\A[\w\-]{5,}\z/i }
  validates :member_since, numericality: { less_than_or_equal_to: Date.today.year, greater_than_or_equal_to: 1995, only_integer: true }, allow_blank: true

  has_paper_trail only: [ :username, :email, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :member_since ]

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
    ps = ps.reject{ |v| v == 'admin' } if no_admin
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
    memberships.where(year: (Date.today.year..Date.today.year + 1)).order('year ASC').first
  end

  # Returns *Boolean*. Determines whether user has a current membership.
  def current_member?
    current_membership.present?
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
    '//gravatar.com/avatar/' + Digest::MD5.hexdigest(email.downcase.sub(/\+.+@/,'@')) + '?d=mm'
  end

  # TODO: Clean the shit out of this import. Stabilize it.

  # User import script. Needs work.
  def self.import(file, privileges = [], override_id)
    allowed_attributes = [:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username]
    spreadsheet = Roo::Spreadsheet.open(file.path.to_s,extension: 'csv')
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      next if row['type'] == 'Relative' # TODO: Allow Relative input

      if row['email'].blank?
        logger.error "No email for #{row['first_name']} #{row['last_name']}"
        next
      end

      user = User.where(email: row['email'].strip.downcase).first_or_initialize
      if user.new_record?
        original_uname = row['username'] = "#{row['first_name']}#{row['last_name']}".downcase.gsub(/[^a-z]/,'')
        i = 0
        until User.find_by(username: row['username']).nil?
          i += 1
          row['username'] = "#{original_uname}#{i}"
        end
      end
      user.attributes = row.to_hash.select { |x| allowed_attributes.include? x.to_sym  }
      pass = false
      if user.new_record?
        logger.info "Adding #{row['first_name']} #{row['last_name']}…"
        user.password = (pass = rand(36**10).to_s(36))
      else
        logger.info "Updating #{row['first_name']} #{row['last_name']}…"
        if user.changed?
           logger.info "  Changed: #{user.changes.keys.to_sentence}"
        else
           logger.info '  No changes' unless user.changed?
        end
      end
      if user.save
        m = user.memberships.where(year: Time.current.year).first_or_initialize
        if m.new_record?
          m.info = { override: override_id }
          m.privileges = privileges
          m.type = row['membership_type'].titleize || 'Individual'
          logger.info "#{m.year} #{m.type} Membership created for #{user.first_name} #{user.last_name} (#{user.username})" if m.save
        end
        UserMailer.new_user_creation_email(user,pass).deliver if pass
      else
        logger.error "  Could not save user #{row['first_name']} #{row['last_name']}:\n  " + user.errors.to_hash.map{|k,v| "#{k}: #{v.to_sentence}"}.join("\n  ")
      end
    end
  end

  # Outputs CSV
  def self.to_csv
    filtered_columns = %w(created_at updated_at encrypted_password reset_password_token reset_password_sent_at remember_created_at current_sign_in_at sign_in_count current_sign_in_ip last_sign_in_ip stripe_customer_token)
    columns_to_use = column_names - filtered_columns

    CSV.generate do |csv|
      csv << (columns_to_use + %w(current_member membership_type)).map(&:titleize)
      all.each do |user|
        csv << user.attributes.values_at(*columns_to_use) + [ user.current_membership.present?, user.current_membership.try(:type) ]
      end
    end
  end

  # Converts the phone to *Integer* for storage.
  def phone= value
    value.gsub!(/\D/,'') if value.is_a? String
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
    if stripe_customer_token
      Stripe::Customer.retrieve(stripe_customer_token)
    else
      nil
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe::InvalidRequestError: #{e}"
  end

end
