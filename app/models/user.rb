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

  scope :scores, -> {
    unscoped.select('*',
      '(SELECT COUNT(*) FROM pick_ems WHERE pick_ems.user_id = users.id AND pick_ems.correct) AS correct_pick_ems',
      '(SELECT COUNT(*) FROM pick_ems WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL) AS total_pick_ems',
      '(SELECT SUM(rev_guesses.score) FROM rev_guesses WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL) AS rev_guesses_score',
      '(SELECT COUNT(*) FROM rev_guesses WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL) AS rev_guesses_count' )
  }

  scope :rev_guess_scores, -> {
    unscoped.select('*',
      '(SELECT SUM(rev_guesses.score) FROM rev_guesses WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL) AS rev_guesses_score',
      '(SELECT COUNT(*) FROM rev_guesses WHERE rev_guesses.user_id = users.id AND rev_guesses.score IS NOT NULL) AS rev_guesses_count' )
  }

  scope :pick_em_scores, -> {
    unscoped.select('*',
      '(SELECT COUNT(*) FROM pick_ems WHERE pick_ems.user_id = users.id AND pick_ems.correct) AS correct_pick_ems',
      '(SELECT COUNT(*) FROM pick_ems WHERE pick_ems.user_id = users.id AND pick_ems.correct IS NOT NULL) AS total_pick_ems' )
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

  accepts_nested_attributes_for :memberships

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
    pick_ems.select{|x| x.match_id == match.id }.try(:first) || PickEm.new
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
  def self.import(file, privileges = [])
    allowed_attributes = [:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username]
    spreadsheet = Roo::Spreadsheet.open(file.path.to_s,extension: 'csv')
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      original_uname = row['username']
      i = 0
      until User.find_by(username: row['username']).nil?
        i += 1
        row['username'] = "#{original_uname}#{i}"
      end
      user = User.new(username: row['username'])
      user.attributes = row.to_hash.select { |x| allowed_attributes.include? :"#{x}"  }
      #pass = false
      #if user.new_record?
      puts "Adding #{row['first_name']} #{row['last_name']}…"
      user.password = (pass = rand(36**10).to_s(36))
      #else
      #  puts "Updating #{row['first_name']} #{row['last_name']}…"
      #  if user.changed?
      #    puts "  Changed: #{user.changes.keys.to_sentence}"
      #  else
      #    puts '  No changes' unless user.changed?
      #  end
      #end
      if user.save
        user.memberships << Membership.create(year: Time.current.year)
        user.current_membership.privileges = privileges
        user.current_membership.type = row['membership_type'] || 'individual'
        UserMailer.new_user_creation_email(user,pass).deliver #if pass
      else
        puts "  Could not save user #{row['first_name']} #{row['last_name']}:"
        puts '  ' + user.errors.to_hash.map{|k,v| "#{k}: #{v.to_sentence}"}.join("\n  ")
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

end
