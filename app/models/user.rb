class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  default_scope { includes(:roles) }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :mot_ms
  has_many :rev_guesses
  has_many :pick_ems

  validates :first_name, :last_name, presence: true
  validates :username, presence: true, uniqueness: true, case_sensitive: false
  validates :username, format: { with: /\A[\w\-]{5,}\z/i }
  validates :member_since, numericality: { less_than_or_equal_to: Date.today.year, greater_than_or_equal_to: 1995, only_integer: true }, allow_blank: true

  has_paper_trail only: [ :username, :email, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :member_since ]

  def role?(r)
    roles.map(&:name).include? r
  end

  def list_roles(verbose: false)
    rs = self.roles.map{|r| r.name.titleize }
    if verbose
      rs.to_sentence
    else
      rs.join(', ')
    end
  end

  def pick_for(match)
    pick_ems.select{|x| x.match_id == match.id }.try(:first) || PickEm.new
  end

  def pick_result(match)
    m = pick_for(match)
    m.nil? ? nil : m.result
  end

  def pick_em_score
    pick_ems ? pick_ems.select{|p| p.correct? }.length : 0
  end

  def rev_guess_score
    rev_guesses.inject(0){|sum,x| sum+(x.score.nil? ? 0 : x.score)}
  end

  def gravatar
    '//gravatar.com/avatar/' + Digest::MD5.hexdigest(email.downcase.gsub(/\+.+@/,'@')) + '?d=mm'
  end

  def self.import(file, roles = [])
    allowed_attributes = [:last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :username]
    spreadsheet = Roo::Spreadsheet.open(file.path.to_s,extension: 'csv')
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      user = find_or_initialize_by(username: row['username'])
      user.attributes = row.to_hash.select { |x| allowed_attributes.include? :"#{x}"  }
      user.roles = roles
      user.roles << Role.find_by(name: row['membership_type']) if row['membership_type']
      pass = false
      if user.new_record?
        puts "Adding #{row['first_name']} #{row['last_name']}…"
        user.password = (pass = rand(36**10).to_s(36))
      else
        puts "Updating #{row['first_name']} #{row['last_name']}…"
        if user.changed?
          puts "  Changed: #{user.changes.keys.to_sentence}"
        else
          puts '  No changes' unless user.changed?
        end
      end
      if user.save
        UserMailer.new_user_creation_email(user,pass).deliver if pass
      else
        puts "  Could not save user #{row['first_name']} #{row['last_name']}:"
        puts '  ' + user.errors.to_hash.map{|k,v| "#{k}: #{v.to_sentence}"}.join("\n  ")
      end
    end
  end

  def phone= value
    value.gsub!(/\D/,'') if value.is_a? String
    super(value)
  end

  def to_param
    username
  end

  def self.text_search(query)
    if query.present?
      where 'username ilike :q or first_name ilike :q or last_name ilike :q or email ilike :q', q: "%#{query}%"
    else
      scoped
    end
  end

end
